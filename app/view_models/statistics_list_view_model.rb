class StatisticsListViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :statistics, :comparison_statistics, :entities_to_bold

  def initialize statistics, options={}
    raise ArgumentError, 'statistics must be an instance of Statistics' unless statistics.is_a? Statistics
    @statistics = statistics
    options.each {|key, value| self.send "#{key}=".to_sym, value }
    self
  end

  def comparison_statistics= cs
    raise ArgumentError, 'comparison_statistics must be an instance of Statistics' unless cs.is_a? Statistics
    @comparison_statistics = cs
    self
  end
  def entities_to_bold= entities
    entities = Array(entities)
    @entities_to_bold = entities
    self
  end

  def render
    content_tag(:div, class: 'statistics-list-view-model') do
      content_tag(:table, class: 'table table-condensed') do
        content_tag(:tbody) do
          render_table_rows
        end
      end +
      render_comparison_explanation
    end
  end

  private

  def render_table_rows
    statistics_results.collect do |result|
      content_tag(:tr) { render_table_row *result }
    end.inject(:+)
  end

  def render_table_row rank, stat, entity, series
    render_comparison(rank, entity) +
    render_rank(rank, entity) +
    render_stat(stat, entity) +
    render_name(entity, series)
  end

  def render_comparison rank, entity
    return '' unless show_comparison?
    previous_rank = comparison_results.select {|_, _, e, _| entity == e }[0].try(:first)

    span_class, icon, title, extra =
      if previous_rank.nil?
        [:new, 'star', 'New', nil]
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
      stat
    end
  end

  def render_name entity, series
    content_tag(:td, class: (:emphasize if should_bold_entity?(entity))) do
      series ? "#{entity} @ #{series}" : entity.to_s
    end
  end

  def render_comparison_explanation
    return '' unless show_comparison?
    content_tag(:small, "(Icons indicate change from previous match day's results.)", class: 'delta-explanation')
  end

  def statistics_results
    @statistics_results ||= statistics.fetch_results
  end

  def comparison_results
    @comparison_results ||= comparison_statistics && comparison_statistics.fetch_results
  end

  def show_comparison?
    !comparison_statistics.nil?
  end

  def should_bold_entity? e
    entities_to_bold && entities_to_bold.include?(e)
  end
end