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
end
