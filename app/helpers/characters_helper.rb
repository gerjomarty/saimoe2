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

  def format_tournament_buttons tournament, m_hash
    stages = m_hash.keys

    content_tag :div, class: 'btn-group' do
      tournament.stages.collect do |stage|

        if (included = stages.include?(stage))
          match = m_hash[stage][:match]
          match_entry = m_hash[stage][:match_entry]

          if match_entry.winner?
            if match.draw?
              btn_type = 'btn-warning'
            else
              btn_type = 'btn-success'
            end
          else
            btn_type = 'btn-danger'
          end

          c = content_tag(:button, class: "match-popover btn #{btn_type}",
                                   'data-original-title' => pretty_match(match)) { pretty_stage stage }
          c << match_popover(match, match_entry)
        else
          # Didn't make it this far in the tournament - show disabled button
          content_tag(:button, class: 'btn', disabled: true) { pretty_stage stage }
        end

      end.join.html_safe
    end
  end

  private

  def match_popover match, curr_match_entry
    content_tag(:div, class: 'match-popover-content', style: 'display: none;') do
      content_tag :table, class: 'table table-condensed' do
        cc = content_tag(:thead) do
          content_tag :tr do
            c = content_tag(:th)
            c << content_tag(:th, 'votes')
            c << content_tag(:th, '% share')
          end
        end
        cc << content_tag(:tbody) do
          match.match_entries.ordered_by_votes.collect do |me|
            current_me = (me == curr_match_entry)
            content_tag :tr do
              c = content_tag(:td) do
                full_name = me.appearance.character_role.character.full_name
                current_me ? content_tag(:strong, full_name) : full_name
              end
              c << content_tag(:td) do
                number_of_votes = me.number_of_votes.to_s
                current_me ? content_tag(:strong, number_of_votes) : number_of_votes
              end
              c << content_tag(:td) do
                vote_share = format_percent(me.vote_share)
                current_me ? content_tag(:strong, vote_share) : vote_share
              end
            end
          end.join.html_safe
        end
      end
    end
  end

end
