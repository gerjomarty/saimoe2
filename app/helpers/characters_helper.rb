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
    v_actors = character.voice_actors.ordered.all
    if v_actors.size == 0
      va_tags = %w{N/A}
    elsif v_actors.size == 1
      va_tags = [link_to(v_actors[0].full_name, voice_actor_path(v_actors[0]))]
    else
      v_actor_roles = character.voice_actor_roles.scoped
      multiple_years = (v_actor_roles.collect {|var| var.appearance.tournament}.uniq.size > 1)
      va_tags = v_actors.collect do |va|
        c = link_to("#{va.full_name}", voice_actor_path(va))
        if multiple_years
          years = v_actor_roles.where(voice_actor_id: va.id).collect {|var| var.appearance.tournament.year}.uniq.sort.join '/'
          c << " (#{years})"
        end
        c
      end
    end
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
    if match_entry.is_winner?
      'btn-success'
    elsif match_entry.is_finished?
      'btn-danger'
    else
      'btn-warning'
    end
  end
end
