def build_match_details year, stage, group, match_no, match_hash, va_hash
  t = Tournament.fy year
  m = Match.create! tournament: t, stage: stage, group: group, date: match_hash[:date],
                    match_number: (match_no == 'null' ? nil : match_no)

  match_hash[:match_entries].each do |me|
    name = me[:actual_name] || me[:name]
    series = Series.where(name: me[:series]).first!
    char = Character.find_by_name_and_series(name, series)
    cr = CharacterRole.where(character_id: char && char.id, series_id: series && series.id).first!
    app = Appearance.where(tournament_id: t && t.id, character_role_id: cr && cr.id).first_or_create! do |a|
      a.character_display_name = me[:name] if me[:actual_name]
    end

    case va_hash[cr]
      when Hash, Array # one or more VAs
        [va_hash[cr]].flatten.each do |va|
          v_actor = VoiceActor.where(first_name: va[:va_first_name], last_name: va[:va_last_name]).first_or_create!
          VoiceActorRole.where(appearance_id: app && app.id, voice_actor_id: v_actor && v_actor.id).first_or_create!
        end
      when Symbol
        VoiceActorRole.where(appearance_id: app && app.id).first_or_create! {|var| var.has_no_voice_actor = true }
      else
        raise "Character #{char.inspect} didn't have a voice actor defined"
    end

    prev_match = me[:previous_match] &&
        Match.where(tournament_id: t && t.id,
                    stage: me[:previous_match][:stage],
                    group: me[:previous_match][:group],
                    match_number: me[:previous_match][:match_number] == 'null' ? nil : me[:previous_match][:match_number]).first!
    if prev_match.nil? && (MatchInfo::STAGES - [:round_1, :round_1_playoff]).include?(stage)
      raise "Possible problem with prev match for match entry #{me.inspect}"
    end
    MatchEntry.create! me.slice(:number_of_votes, :position).merge(match: m, appearance: app, previous_match: prev_match)
  end
end

$stderr.print "Initialising tournaments..."

(2002..2011).each do |year|
  t = Tournament.find_or_initialize_by_year year.to_s
  t.group_stages = case year
    when 2002
      [:round_1, :round_1_playoff, :round_2, :round_2_playoff, :round_3, :group_final]
    when 2003
      [:round_1, :round_1_playoff, :round_2, :round_3, :group_final]
    when 2004, 2010
      [:round_1, :round_2, :group_final]
    when 2005..2009, 2011
      [:round_1, :round_2, :round_3, :group_final]
    else
      raise "Year #{year} doesn't have stages defined"
  end
  finals = [:quarter_final, :semi_final, :final]
  finals.unshift :last_16 if year == 2002
  t.final_stages = finals
  t.save!
end

$stderr.puts " done!"

$stderr.print "Loading series..."

YAML::load(File.open("#{Rails.root}/lib/data/series.yml")).each do |s|
  Series.create! name: s[:name], color_code: s[:colour_code]
end

$stderr.puts " done!"

$stderr.print "Loading character data..."

characters = YAML::load(File.open("#{Rails.root}/lib/data/character_data.yml"))
cr_va_mapping = {}

# Need to create main characters and roles before doing cameo roles.
characters.sort_by {|c| c[:role_type] == :cameo ? 1 : 0}.each do |c|
  char_role = nil
  if c[:role_type] != :cameo
    # Main character and role
    series = Series.where(name: c[:series]).first_or_create!
    character = Character.where(c.slice(:first_name, :last_name, :given_name)
                                 .merge(main_series_id: series && series.id)).first_or_create!
    char_role = CharacterRole.create! c.slice(:role_type).merge(character: character, series: series)
  else
    # Character in a cameo role
    cameo_series = Series.where(name: c[:series]).first_or_create!
    main_series = Series.where(name: c[:main_series]).first_or_create!
    character = Character.where(c.slice(:first_name, :given_name, :last_name)
                                 .merge(main_series_id: main_series && main_series.id)).first!
    char_role = CharacterRole.create! c.slice(:role_type).merge(character: character, series: cameo_series)
  end

  # Keep a record of the voice actor per character role for later
  cr_va_mapping[char_role] = if c[:multiple_vas]
    c[:multiple_vas]                       # Array
  elsif c[:va] && c[:va] == :without
    :without                               # Symbol
  elsif c[:va_first_name] || c[:va_last_name]
    c.slice(:va_first_name, :va_last_name) # Hash
  else
    nil
  end
end

$stderr.puts " done!"

(2002..2011).each do |year|
  year = year.to_s
  $stderr.print "Loading match data from #{year}..."

  results = YAML::load(File.open("#{Rails.root}/lib/data/#{year}_results.yml"))

  # First, make sure we have all of the characters already loaded properly.
  results[:group_stages].values.collect(&:values).flatten.collect(&:values).flatten.collect {|match_h| match_h[:match_entries]}.flatten.collect {|me|
    me.slice(:name, :actual_name, :series)
  }.flatten.uniq.each { |cs|
    Character.find_by_name_and_series(cs[:actual_name] || cs[:name], Series.where(name: cs[:series]).first!) or raise <<_ERROR
      #{year}: Problem with #{cs.inspect}. Checking Character, Series and CharacterRole...
      Character: #{Character.find_by_name(cs[:actual_name] || cs[:name]).inspect}
      Series: #{Series.find_by_name(cs[:series]).inspect}
      CharacterRole: #{CharacterRole.where(character_id: (c = Character.find_by_name(cs[:actual_name] || cs[:name])) && c.id,
                                           series_id: (s = Series.find_by_name(cs[:series])) && s.id).first.inspect}
_ERROR
  }

  $stderr.puts " done!"

  $stderr.print "Creating tournament structure for #{year}..."

  results[:group_stages].each do |stage, r1|
    r1.each do |group, r2|
      r2.each do |match_no, r3|
        build_match_details year, stage, group, match_no, r3, cr_va_mapping
      end
    end
  end

  if results[:final_stages]
    results[:final_stages].each do |stage, r1|
      r1.each do |match_no, r2|
        build_match_details year, stage, nil, match_no, r2, cr_va_mapping
      end
    end
  end

  $stderr.puts " done!"
end