module ApplicationHelper
  # Takes a float between 0 and 1, and outputs a percentage with up to two decimal places
  def format_percent number
    num = number * 100
    if fewer_decimal_places_than num, 1
      "%.0f%%" % num
    elsif fewer_decimal_places_than num, 2
      "%.1f%%" % num
    else
      "%.2f%%" % num
    end
  end

  # Renders a nice box with avatar, character name, and series
  def character_entry character, options={}
    display_name = avatar_url = series = votes = is_winner = nil
    if character.is_a? MatchEntry
      app = character.appearance
      votes = character.number_of_votes
      is_winner = character.winner?
      display_name = app.character_display_name
      avatar_url = app.character_avatar(:thumb) if app.character_avatar?
      series = app.character_role.series
      character = app.character_role.character
    end
    display_name ||= character.full_name
    avatar_url ||= character.avatar_url(:thumb)
    series ||= character.main_series

    options[:right_align] = false if options[:right_align].nil?
    options[:show_avatar] = true if options[:show_avatar].nil?
    options[:show_series] = true if options[:show_series].nil?
    options[:show_color] = false if options[:show_color].nil?
    options[:show_votes] = !votes.nil? if options[:show_votes].nil?
    options[:fixed_width] = true if options[:fixed_width].nil?

    color_code = series.color_code

    div_class = "thumbnail character_entry"
    div_class << " right" if options[:right_align]
    div_class << " hide_series" unless options[:show_series]
    div_class << " fixed_width" if options[:fixed_width]
    div_class << " no_avatar" if options[:fixed_width] && !options[:show_avatar]
    if options[:show_color] && color_code
      #div_class << (bright_color(color_code) ? " dark_text" : " light_text")
      div_class << " dark_text"
    end

    content_tag :div,
                class: div_class,
                style: ("background-color: ##{color_code};" if options[:show_color] && color_code) do
      c = ""
      if options[:show_avatar]
        c << content_tag(:div,
                         class: 'character_image') do
          image_tag avatar_url,
                    alt: display_name,
                    size: '40x40'
        end
      end
      if votes && options[:show_votes]
        c << content_tag(:div,
                         class: "character_votes#{(is_winner ? ' winner' : ' loser') if options[:show_color]}") do

          content_tag :p, votes.to_s
        end
      end
      c << content_tag(:div,
                       class: 'character_name') do
        link_to display_name,
                character_path(character),
                title: display_name
      end
      if options[:show_series]
        c << content_tag(:div,
                         class: 'series_name') do
          content_tag(:em,
                      link_to(series.name,
                              series_path(series),
                              title: series.name))
        end
      end
      c << content_tag(:div, '', class: 'cb')
      c.html_safe
    end
  end

  def pretty_match match
    case match.stage
      when :final
        'Grand Final'
      when :semi_final, :quarter_final, :last_16
        "#{pretty_stage match.stage} #{match.match_number}"
      when :group_final
        "#{pretty_group match.group} Final"
      else
        "#{pretty_stage match.stage} Match #{match.group.upcase}#{match.match_number}"
    end
  end

  def short_pretty_match match
    case match.stage
      when :final
        'Final'
      when :semi_final
        "SF#{match.match_number}"
      when :quarter_final
        "QF#{match.match_number}"
      when :last_16
        "L16 #{match.match_number}"
      when :group_final
        "#{match.group.upcase} Final"
      else
        "#{match.group.upcase}#{match.match_number}"
    end
  end

  def pretty_stage stage
    case stage
      when :final
        'Grand Final'
      else
        stage.to_s.gsub(/_/, ' ').titleize
    end
  end

  def pretty_group group
    return '' unless group
    "group #{group}".titleize
  end

  def format_history_tournament_buttons tournament, m_hash
    stages = m_hash.keys

    content_tag :div, class: 'btn-group' do
      tournament.stages.collect do |stage|
        if stages.include? stage
          render(partial: 'shared/history_popover_button',
                 locals: {stage: stage,
                          match_entries: m_hash[stage].uniq})
        else
          # Didn't make it this far in the tournament - show disabled button
          unless MatchInfo::PLAYOFF_STAGES.include?(stage)
            content_tag(:button, class: 'btn', disabled: true) { pretty_stage stage }
          end
        end
      end.join.html_safe
    end
  end

  def history_button_type_for match_entries
    return '' unless match_entries
    match_entries.any?(&:winner?) ? 'btn-success' : 'btn-danger'
  end

  def popover_content_for match_entries
    return '' unless match_entries
    winners = match_entries.select(&:winner?)
    losers = match_entries - winners
    div_span = (winners.empty? || losers.empty?) ? 12 : 6

    content_tag :div, class: 'row-fluid' do
      mes = []
      mes << [winners, 'Winners'] unless winners.empty?
      mes << [losers, 'Losers'] unless losers.empty?

      mes.collect do |entries, title|
        content_tag :div, class: "span#{div_span}" do
          c = content_tag :h3, title
          c << entries.collect do |entry|
            content_tag :p do
              cc = content_tag :small, short_pretty_match(entry.match)
              cc << '&nbsp;'.html_safe + entry.character_name
            end
          end.join.html_safe
        end
      end.join.html_safe
    end
  end

  def bright_color hex_string
    return nil unless hex_string
    rgb = hex_string.sub(/\A#/, '').scan(/../).map {|color| color.to_i(16)}
    (0.2126*rgb[0] + 0.7152*rgb[1] + 0.0722*rgb[2]) > 128
  end

  def table_date_height match, hierarchy
    height = hierarchy ? hierarchy.deep_find(match) : 1
    height = height.sum_leaf_nodes if height.kind_of?(Enumerable)
    # TODO: Yes, these are magic, but they work for now. Need to work out definite heights.
    "#{(height*3.462)+((height-1)*0.23)}em"
  end

  def table_votes_height match_entry, hierarchy
    if (match = match_entry.previous_match)
      height = hierarchy ? hierarchy.deep_find(match) : 1
      height = height.sum_leaf_nodes if height.kind_of?(Enumerable)
      if match.draw?
        height = height.to_f / match.winning_match_entries.count.to_f
      end
    else
      height = 1
    end
    # TODO: Yes, these are magic, but they work for now. Need to work out definite heights.
    "#{(height*3.462)+((height-1)*0.23)}em"
  end

  private

  def fewer_decimal_places_than number, places
    decimals = 0
    while number != number.to_i
      decimals += 1
      number *= 10
      return false if decimals >= places
    end
    decimals < places
  end
end
