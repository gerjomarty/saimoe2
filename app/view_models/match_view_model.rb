class MatchViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :match
  attr_accessor :match_name, :info_position, :table_margins, :show_percentages

  def initialize match, options={}
  	@match = match
    options.each {|key, value| self.send "#{key}=".to_sym, value }
  	self
  end

  def render
  	content_tag :div, class: "match-view-model #{info_position_class}", style: style do
      ''.tap do |outer_tag|
        outer_tag << match_entries_div
        outer_tag << content_tag(:div, '', class: 'cb') if info_position == :bottom
        outer_tag << match_info_div
        outer_tag << content_tag(:div, '', class: 'cb')
      end.html_safe
    end
  end

  def match_name
    @match_name.nil? ? false : @match_name
  end
  def match_name= strategy
    allowed_values = [:short, :long, false]
    raise ArgumentError, "match_name must be one of #{allowed_values.inspect}" unless allowed_values.include?(strategy)
    @match_name = strategy
  end
  def info_position
    @info_position.nil? ? :right : @info_position
  end
  def info_position= strategy
    allowed_values = [:left, :right, :bottom]
    raise ArgumentError, "info_position must be one of #{allowed_values.inspect}" unless allowed_values.include?(strategy)
    @info_position = strategy
  end
  def table_margins
    @table_margins.nil? ? false : @table_margins
  end
  def show_percentages
    @show_percentages.nil? ? false : @show_percentages
  end

  private

  def match_entries
  	@match_entries ||= match.match_entries.ordered_by_position
  end

  def match_info_content
    content_tag :span do
      ''.tap do |content|
        content << match_date_content
        if match_extra_content
          content << tag(:br)
          content << content_tag(:span) { match_extra_content }
        end
      end.html_safe
    end
  end

  def match_date_content
    link_to(match.date.to_s(:month_day), date_path(match.date.to_s(:number)))
  end

  def match_extra_content
    extra_divs = [match_name_content, playoff_content].compact
    return nil if extra_divs.empty?
    extra_divs.join(tag(:br)).html_safe
  end

  def match_name_content
    if match_name
      match.pretty(match_name)
    end
  end

  def playoff_content
    if next_match_playoff
      link_to(date_path(next_match_playoff.date.to_s(:number)),
        rel: :html_popover, data: {trigger: :hover, placement: :bottom, container: :body}) do
        "went to playoff"
      end +
      content_tag(:div, rel: :html_popover_content) do
        MatchViewModel.new(next_match_playoff, match_name: :short).render
      end
    end
  end

  # If the winner of this match heads into a playoff, we don't want to show the winner
  # of this match, but instead we want to show the winner of that playoff
  def next_match_playoff
    return @next_match_playoff unless @next_match_playoff.nil?
    next_mes = match.next_match_entries.includes(:match)
    @next_match_playoff =
      if !next_mes.empty? && next_mes.all? {|me| me.match.playoff_match? }
        next_mes[0].match
      else
        false
      end
  end

  # Rendering

  def info_position_class
    case info_position
    when :left   then 'info-left'
    when :right  then 'info-right'
    when :bottom then 'info-bottom'
    end
  end

  def match_entries_div
    content_tag :div, class: "match-entries #{info_position_class}" do
      ''.tap do |mes_tag|
        match_entries.each.with_index do |me, i|
          mes_tag << CharacterEntry.new(me, show_color: true, transparency: transparency_strategy, right_align: alignment_strategy(me) == :right_align, show_percentage: show_percentages).render
          mes_tag << content_tag(:div, '', class: 'cb') if info_position == :bottom && i.odd?
        end
      end.html_safe
    end
  end

  def match_info_div
    style = "height: #{(3.657 * match_entries.size) - 1}em; line-height: #{3.657 * match_entries.size}em;" unless info_position == :bottom
    content_tag :div, class: "match-date #{text_color_class} #{info_position_class}", style: style do
      match_info_content
    end
  end

  # Style

  # TODO: DRY up this code, as it's also in CharacterEntry
  def bright_color? hex_string
    return nil unless hex_string
    red, green, blue = hex_string.sub(/\A#/, '').scan(/../).map {|color| color.to_i(16)}
    (0.299*red + 0.587*green + 0.114*blue) > 100
  end

  def transparency_strategy
    if next_match_playoff
      true
    else
      :all_but_winner
    end
  end

  def alignment_strategy match_entry=nil
    case info_position
    when :left then :right_align
    when :right then :left_align
    when :bottom
      (match_entry.nil? || match_entries.index(match_entry).even?) ? :left_align : :right_align
    end
  end

  def background_colors
    case (mes = (next_match_playoff || match).winning_match_entries).size
    when 0
      return %w(#D3D3D3)
    when 1
      return %W(##{mes[0].series.color_code})
    else
      return [mes.first, mes.last].collect {|me| "##{me.series.color_code}" }
    end
  end

  def text_color_class
    if background_colors.collect {|bc| bright_color?(bc) }.any?
      'dark_text'
    else
      'light_text'
    end
  end

  def style
    [background_style, table_margins_style].compact.join(' ')
  end

  def background_style
    if background_colors.size == 1
      "background-color: #{background_colors[0]};"
    else
      <<-STYLE
        background: #D3D3D3;
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#{background_colors[0]}', endColorstr='#{background_colors[1]}');
        background: -webkit-gradient(linear, left top, left bottom, from(#{background_colors[0]}), to(#{background_colors[1]}));
        background: -moz-linear-gradient(top, #{background_colors[0]}, #{background_colors[1]});
      STYLE
    end
  end

  def table_margins_style
    if table_margins
      margin = ViewSizing.match_tournament_margin match_entries.size, match.base_match_entry_counts(match.playoff_group?)
      height = ViewSizing.mvm_outer_height match.base_match_entry_counts(match.playoff_group?)
      "padding-bottom: #{margin}em; padding-top: #{margin}em;"
    end
  end

end