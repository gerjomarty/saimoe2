class WinnersLosersPopoverViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :winners, :losers, :unfinished

  def to_partial_path
    'view_models/winners_losers_popover'
  end

  def initialize winners, losers, unfinished
    @winners = winners || []
    @losers = losers || []
    @unfinished = unfinished || []
    self
  end

  def render
    content_tag :div, class: 'winners-losers-popover-view-model' do
      (yet_to_play_div + winners_losers_div).html_safe
    end
  end

  def yet_to_play_div
    return '' if unfinished.none?
    content_tag(:div, class: 'row-fluid') do
      content_tag(:div, class: 'span12') do
        content_tag(:h4, 'Yet to play') +
        render_list(unfinished)
      end
    end
  end

  def winners_losers_div
    content_tag(:div, class: 'row-fluid') do
      (winners_div + losers_div).html_safe
    end
  end

  private

  def winners_div
    return '' if winners.none?
    content_tag(:div, class: winners_losers_class) do
      content_tag(:h4, 'Winners') +
      render_list(winners, winners_table_class)
    end
  end

  def losers_div
    return '' if losers.none?
    content_tag(:div, class: winners_losers_class) do
      content_tag(:h4, 'Losers') +
      render_list(losers, losers_table_class)
    end
  end

  def winners_losers_class
    if winners.any? && losers.any?
      'span6'
    else
      'span12'
    end
  end

  def winners_table_class
    if winners.any? && losers.any?
      'left-table'
    end
  end

  def losers_table_class
    if winners.any? && losers.any?
      'right-table'
    end
  end

  def render_list info, table_class=nil
    content_tag(:table, class: table_class) do
      content_tag(:tbody) do
        info.collect do |i|
          content_tag(:tr) do
            content_tag(:td, class: 'stage') { content_tag(:small, i[:match].pretty(:short).gsub(' ', '&nbsp;').html_safe) } +
            content_tag(:td, class: 'character') { i[:match_entry].character_name }
          end
        end.inject(:+)
      end
    end
  end
end