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
  def character_entry character, right_align=false, hide_series=false, series=nil
    content_tag :div, class: "thumbnail character_entry#{' right' if right_align}#{' hide_series' if hide_series}" do
      c = content_tag :div, class: 'character_image' do
        image_tag character.avatar_url(:thumb), size: '40x40'
      end
      c << content_tag(:div, class: 'character_name') do
        link_to character.full_name, character_path(character)
      end
      unless hide_series
        series ||= character.main_series
        c << content_tag(:div, class: 'series_name') do
          content_tag(:em, link_to(series.name, series_path(series)))
        end
      end
      c << content_tag(:div, '', class: 'cb')
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
