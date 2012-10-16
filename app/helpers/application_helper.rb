module ApplicationHelper
  # Takes a float between 0 and 1, and outputs a percentage with up to two decimal places
  def format_percent number
    num = number * 100
    format_float(num) << "%"
  end

  def format_float number
    if fewer_decimal_places_than number, 1
      "%.0f" % number
    elsif fewer_decimal_places_than number, 2
      "%.1f" % number
    else
      "%.2f" % number
    end
  end

  # Renders a nice box with avatar, character name, and series
  def character_entry character, options={}
    display_name = avatar_url = series = votes = is_winner = nil
    if character.is_a? MatchEntry
      m_entry = character
      app = m_entry.appearance
      votes = m_entry.number_of_votes
      is_winner = m_entry.is_winner?
      display_name = m_entry.character_name
      avatar_url = app.character_avatar_url(:thumb) if app.character_avatar?
      series = m_entry.series
      character = m_entry.character
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
    options[:fade_out] = false if options[:fade_out].nil?

    color_code = series.color_code

    div_class = "thumbnail character_entry"
    div_class << " right" if options[:right_align]
    div_class << " hide_series" unless options[:show_series]
    div_class << " fixed_width" if options[:fixed_width]
    div_class << " no_avatar" if options[:fixed_width] && !options[:show_avatar]
    div_class << " fade_out" if options[:fade_out]
    if options[:show_color] && color_code
      div_class << (bright_color(color_code) ? " dark_text" : " light_text")
      #div_class << " dark_text"
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
    if match_entries.any?(&:is_winner?)
      'btn-success'
    elsif match_entries.all?(&:is_finished?)
      'btn-danger'
    else
      'btn-warning'
    end
  end

  def popover_content_for match_entries
    return '' unless match_entries
    winners = match_entries.select(&:is_winner?)
    losers = match_entries.select(&:is_finished?) - winners
    yet_to_play = match_entries - winners - losers

    content = ''
    unless yet_to_play.empty?
      content << content_tag(:div, class: 'row-fluid') do
        content_tag(:div, class: 'span12') do
          d = content_tag :h3, 'Yet to play'
          d << yet_to_play.collect do |entry|
            content_tag :p do
              dd = content_tag :small, short_pretty_match(entry.match)
              dd << '&nbsp;'.html_safe + entry.character_name
            end
          end.join.html_safe
        end
      end
    end

    div_span = (winners.empty? || losers.empty?) ? 12 : 6
    content << content_tag(:div, class: 'row-fluid') do
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

    content.html_safe
  end

  def bright_color hex_string
    return nil unless hex_string
    rgb = hex_string.sub(/\A#/, '').scan(/../).map {|color| color.to_i(16)}
    (0.299*rgb[0] + 0.587*rgb[1] + 0.114*rgb[2]) > 100
  end

  def table_date_height match
    return '' unless match
    height = match.table_height
    # TODO: Yes, these are magic, but they work for now. Need to work out definite heights.
    "#{(height*3.462)+((height-1)*0.23)}em"
  end

  def table_votes_height match_entry
    return '' unless match_entry
    height = match_entry.table_height
    # TODO: Yes, these are magic, but they work for now. Need to work out definite heights.
    "#{(height*3.462)+((height-1)*0.23)}em"
  end

  def table_date_background_color match
    if match.is_finished?
      if match.next_match_entries.includes(:match).all? {|me| me.match.playoff_match?}
        # Previous winner went to a playoff - we want to show the winner of that playoff instead
        match = match.next_match_entries.includes(:match).first.match
      end
      if !match.is_draw? && (color = match.winning_match_entries.first.series.color_code)
        return " background-color: ##{color};"
      end
    end
    ''
  end

  def match_entry_votes_box match, match_entry
    playoff_match = if match_entry && match_entry.match && match_entry.match.next_match_entries.includes(:match).all? {|me| me.match.playoff_match?}
                      match_entry.match.next_match_entries.includes(:match).first.try(:match)
                    end
    vote_height = table_votes_height match_entry
    class_statement = 'match_votes'.tap do |string|
      if match && match.is_finished?
        if match_entry && match_entry.is_winner?
          string << ' winner'
          if playoff_match
            string << ' button-popover playoff-loser-votes'
          else
            if match_entry.try(:series).try(:color_code)
              string << (bright_color(match_entry.series.color_code) ? ' dark_text' : ' light_text')
            else
              string << ' dark_text'
            end
          end
        else
          string << ' loser'
        end
      end
    end
    data_hash = if match && match_entry && match.is_finished? && match_entry.is_winner? && playoff_match
                  {data: {original_title: "#{playoff_match.date.to_s(:month_day)}: #{pretty_match playoff_match}"}}
                else
                  {}
                end
    p_style_statement = if match_entry && match_entry.is_finished? && match_entry.is_winner? && !playoff_match
                          "background-color: ##{match_entry.series.color_code};"
                        end
    c = content_tag(:div, data_hash.merge(class: class_statement, style: "height: #{vote_height}; line-height: #{vote_height};")) do
      content_tag :p, match_entry.try(:number_of_votes) || '', {style: p_style_statement}
    end
    if match_entry && match_entry.is_finished? && match_entry.is_winner? && playoff_match
      c << content_tag(:div, class: 'button-popover-content', style: 'display: none;') do
        playoff_match.match_entries.ordered_by_position.collect { |p_me|
          character_entry(p_me, show_color: true, show_votes: true)
        }.join.html_safe
      end
    end
    c
  end

  def match_date_box match
    return '' unless match
    date_height = table_date_height match
    if match && match.is_finished? && match.next_match_entries.includes(:match).all? {|me| me.match.playoff_match?}
      # Previous winner went to a playoff - we want to show the winner of that playoff instead
      match = match.next_match_entries.includes(:match).first.try(:match)
    end
    class_statement = 'match_votes'
    div_style = "height: #{date_height}; line-height: #{date_height};"
    if match && match.is_draw?
      colors = match.winning_match_entries.collect {|me| me.series.color_code}.compact[0..1]
      class_statement << (colors.none? {|c| bright_color c} ? ' light_text' : ' dark_text')
      div_style << " background: #FFFFFF;
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='##{colors[0]}', endColorstr='##{colors[1]}');
        background: -webkit-gradient(linear, left top, left bottom, from(##{colors[0]}), to(##{colors[1]}));
        background: -moz-linear-gradient(top, ##{colors[0]}, ##{colors[1]});"
    elsif (color = match && match.winning_match_entries.first.try(:series).try(:color_code))
      class_statement << (bright_color(color) ? ' dark_text' : ' light_text')
      div_style << " background-color: ##{color};"
    end
    if match && !match.is_draw? && (color = match.winning_match_entries.first.try(:series).try(:color_code))
      class_statement << (bright_color(color) ? ' dark_text' : ' light_text')
      div_style << " background-color: ##{color};"
    end
    content_tag :div, class: class_statement, style: div_style do
      content_tag :p do
        link_to(match.date.to_s(:month_day), date_path(match.date.to_s(:number)))
      end
    end
  end

  def table_votes_class match, match_entry, playoff_match=nil
    'match_votes'.tap do |string|
      if match.is_finished?
        if match_entry.is_winner?
          string << ' winner'
          if playoff_match
            string << ' button-popover playoff-loser-votes'
          else
            string << (bright_color(match_entry.series.color_code) ? ' dark_text' : ' light_text')
          end
        else
          string << ' loser'
        end
      end
    end
  end

  def table_votes_extra_style match_entry
    if match_entry.is_finished? && match_entry.is_winner?
      if match_entry.match.next_match_entries.includes(:match).all? {|me| me.match.playoff_match?}
        return ' background-color: #FF0000; color: #D3D3D3; font-style: italic;'
      elsif (color = match_entry.series.color_code)
        font_color = bright_color(color) ? '#000000' : '#FFFFFF'
        return " color: #{font_color}; background-color: ##{color};"
      end
    end
    ''
  end

  def table_date_extra_style match
    if match.is_finished?
      if match.next_match_entries.includes(:match).all? {|me| me.match.playoff_match?}
        # Previous winner went to a playoff - we want to show the winner of that playoff instead
        match = match.next_match_entries.includes(:match).first.match
      end
      if !match.is_draw? && (color = match.winning_match_entries.first.series.color_code)
        return " color: #{bright_color(color) ? '#000000' : '#FFFFFF'};"
      end
    end
    ''
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
