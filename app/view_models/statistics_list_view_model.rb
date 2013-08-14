class StatisticsListViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :statistics, :comparison_statistics, :entities_to_bold

  def to_partial_path
    'view_models/statistics_list'
  end

  def dependencies
    [statistics.hash, comparison_statistics.try(:hash), entities_to_bold].compact
  end

  def initialize statistics, options={}
    raise ArgumentError, 'statistics must be an instance of Statistics' unless statistics.is_a? Statistics
    @statistics = statistics
    options.each {|key, value| self.send "#{key}=".to_sym, value }
    self
  end

  def comparison_statistics= cs
    raise ArgumentError, 'comparison_statistics must be an instance of Statistics' unless cs.nil? or cs.is_a? Statistics
    @comparison_statistics = cs
    self
  end
  def entities_to_bold= entities
    entities = Array(entities)
    @entities_to_bold = entities
    self
  end

  def show_comparison?
    !comparison_statistics.nil?
  end

  def render_table_rows stage_name, results
    results.collect do |result|
      content_tag(:tr) { render_table_row stage_name, *result }
    end.inject(:+)
  end

  def statistics_results
    return @statistics_results if @statistics_results

    results = statistics.fetch_results
    if results.is_a? Hash
      @statistics_results = results.collect {|r| [MatchInfo.pretty_stage(r[0]), r[1]]}
    else
      @statistics_results = [[nil, results]]
    end
  end

  private

  def render_table_row stage_name, rank, stat, entity, series
    (render_comparison(stage_name, rank, entity) +
    render_rank(rank, entity) +
    render_stat(stat, entity) +
    render_name(entity, series)).html_safe
  end

  def render_comparison stage_name, rank, entity
    return '' unless show_comparison?
    if comparison_results.is_a? Hash
      previous_rank = comparison_results[stage_name] && comparison_results[stage_name].select {|_, _, e, _| entity == e }[0].try(:first)
    else
      previous_rank = comparison_results.select {|_, _, e, _| entity == e }[0].try(:first)
    end

    span_class, icon, title, extra =
      if previous_rank.nil?
        [:new, 'star', 'New', '(New)']
      elsif rank < previous_rank
        [:up, 'arrow-up', "Up #{previous_rank - rank}", "(#{previous_rank - rank})"]
      elsif rank > previous_rank
        [:down, 'arrow-down', "Down #{rank - previous_rank}", "(#{rank - previous_rank})"]
      else
        [:nonmover, 'minus', 'Non-mover', nil]
      end

    content_tag(:td, class: :indicator) do
      content_tag(:span, class: span_class) do
        extra_tag = extra ? content_tag(:small, extra) : ''
        icon_tag = content_tag(:i, '', class: "icon-#{icon}", title: title)
        (extra_tag + '&nbsp;'.html_safe + icon_tag).html_safe
      end
    end
  end

  def render_rank rank, entity
    content_tag(:td, class: (:emphasize if should_bold_entity?(entity))) do
      rank.ordinalize
    end
  end

  def render_stat stat, entity
    content_tag(:td, class: (:emphasize if should_bold_entity?(entity))) do
      statistics.render_function.call(stat)
    end
  end

  def render_name entity, series
    content_tag(:td, class: (:emphasize if should_bold_entity?(entity))) do
      tag = link_to(entity.to_s, polymorphic_path(entity))
      tag += (' @ ' + link_to(series.to_s, polymorphic_path(series))).html_safe if series
      tag
    end
  end

  def comparison_results
    return @comparison_results if @comparison_results

    results = comparison_statistics.fetch_results
    if results.is_a? Hash
      results.keys.each {|k| results[MatchInfo.pretty_stage(k)] = results.delete(k) }
    end
    @comparison_results = results
  end

  def should_bold_entity? e
    entities_to_bold && entities_to_bold.include?(e)
  end
end