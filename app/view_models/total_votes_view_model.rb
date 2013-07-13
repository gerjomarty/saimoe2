class TotalVotesViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :entity

  def initialize entity
    @entity = entity
    self
  end

  def render
    content_tag(:div, class: 'total-votes-view-model') do
      content_tag(:h4, 'Total number of votes across all tournaments') +
      content_tag(:table, class: 'table table-condensed') do
        content_tag(:tbody) do
          render_table_rows
        end
      end +
      content_tag(:small, "(Icons indicate change from previous match day's results.)", class: 'delta-explanation')
    end
  end

  private

  def render_table_rows
    current_statistics.collect do |rank, stat, e, series|
      content_tag(:tr) { render_table_row(rank, stat, e, series) }
    end.inject(:+)
  end

  def render_table_row current_rank, stat, row_entity, row_series
    previous_rank = previous_statistics.select {|_, _, e, _| row_entity == e }[0].try(:first)
    tag_class = 'current' if entity == row_entity

    name = link_to row_entity.to_s, polymorphic_path(row_entity)
    name += " @ #{link_to row_series.to_s, series_path(row_series)}".html_safe if row_series

    content_tag(:td, class: :indicator) { movement_indicator(current_rank, previous_rank) } +
    content_tag(:td, class: tag_class) { current_rank.ordinalize } +
    content_tag(:td, class: tag_class) { stat.to_s } +
    content_tag(:td, class: tag_class) { name }
  end

  def current_statistics
    @current_statistics ||= Statistics.new(entity.class)
                                      .get_statistic(:total_votes)
                                      .for_entity(entity, true)
                                      .fetch_results
  end

  def previous_statistics
    @previous_statistics ||= Statistics.new(entity.class)
                                       .get_statistic(:total_votes)
                                       .before_date(most_recent_date)
                                       .fetch_results
  end

  def most_recent_date
    @most_recent_date ||= Match.where(is_finished: true).maximum(Match.q_column :date).to_date
  end

  def movement_indicator current_rank, previous_rank
    if previous_rank.nil?
      span_class, icon, title, extra = :new, 'star', 'New', nil
    elsif current_rank < previous_rank
      delta = previous_rank - current_rank
      span_class, icon, title, extra = :up, 'arrow-up', "Up #{delta}", "(#{delta})"
    elsif current_rank > previous_rank
      delta = current_rank - previous_rank
      span_class, icon, title, extra = :down, 'arrow-down', "Down #{delta}", "(#{delta})"
    else
      span_class, icon, title, extra = :nonmover, 'minus', 'Non-mover', nil
    end

    content_tag(:span, class: span_class) do
      extra_tag = extra ? content_tag(:small, extra) : ''
      icon_tag = content_tag(:i, '', class: "icon-#{icon}", title: title)
      (extra_tag + '&nbsp;'.html_safe + icon_tag).html_safe
    end
  end
end