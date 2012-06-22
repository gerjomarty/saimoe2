module CharactersHelper
  def format_other_series_list character
    series = character.other_series
    unless series.empty?
      content_tag :h4 do
        "Also appears in: ".html_safe +
            series.collect {|s| content_tag(:em, link_to(s.name, series_path(s)))}.join(', ').html_safe
      end
    end
  end

  def format_voice_actor_list character
    va_tags = character.voice_actors.collect {|va| link_to va.full_name, voice_actor_path(va)}
    va_string = "Voice actor".pluralize(va_tags.size)
    content_tag :h3 do
      (va_string << ': ' << va_tags.join(', ')).html_safe
    end
  end

  def format_character_tournament_buttons tournament, m_hash
    stages = m_hash.keys

    content_tag :div, class: 'btn-group' do
      tournament.stages.collect do |stage|

        if stages.include? stage
          render(partial: 'shared/match_popover_button',
                 locals: {stage: stage,
                          match: m_hash[stage][:match],
                          current_match_entry: m_hash[stage][:match_entry]})
        else
          # Didn't make it this far in the tournament - show disabled button
          unless MatchInfo::PLAYOFF_STAGES.include?(stage)
            content_tag(:button, class: 'btn', disabled: true) { pretty_stage stage }
          end
        end

      end.join.html_safe
    end
  end

  def button_type_for match_entry
    return '' unless match_entry
    match_entry.winner? ? 'btn-success' : 'btn-danger'
  end
end
