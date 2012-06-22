module ApplicationHelper
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

  def pretty_match match, short_form=false
    if match.stage == :final
      short_form ? 'Final' : 'Grand Final'
    elsif MatchInfo::FINAL_STAGES.include? match.stage
      if short_form
        "#{pretty_stage(match.stage).gsub(/[a-z\s]/, '')}#{match.match_number}"
      else
        "#{pretty_stage match.stage} #{match.match_number}"
      end
    elsif match.stage == :group_final
      short_form ? "#{match.group.upcase} Final" : "#{pretty_group match.group} Final"
    elsif short_form && match.stage == :round_1
      "#{match.group.upcase}#{match.match_number.to_s.rjust(2, '0')}"
    else
      if short_form
        "#{match.group.upcase}#{match.stage.to_s.gsub(/[^\d]/, '')}-#{match.match_number}"
      else
        m_no = match.stage == :round_1 ? match.match_number.to_s.rjust(2, '0') : match.match_number.to_s
        "#{pretty_stage match.stage} Match #{match.group.upcase}#{m_no}"
      end
    end
  end

  def pretty_stage stage
    return '' unless stage
    return 'Grand Final' if stage == :final
    stage.to_s.gsub(/_/, ' ').titleize
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
              cc = content_tag :small, pretty_match(entry.match, true)
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
