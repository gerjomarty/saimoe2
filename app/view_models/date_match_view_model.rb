class DateMatchViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include Rails.application.routes.url_helpers

  attr_reader :match

  def initialize match
    @match = match
    self
  end

  def render
    content_tag(:div, class: 'date-match-view-model container-fluid') do
      content_tag(:div, class: 'row-fluid') do
        content_tag(:div, class: 'span5') { render_match_view } +
        content_tag(:div, class: 'span7') { render_match_vote_graph }
      end
    end
  end

  private

  def render_match_view
    render_title +
    content_tag(:div, class: 'match-view') { render_match }
  end

  def render_title
    votes = if match.is_finished?
              content_tag(:small, "(#{pluralize(match.number_of_votes, 'vote')} total)")
            else
              ''
            end
    content_tag(:h3) do
      (match.pretty + ' ' + votes).html_safe
    end
  end

  def render_match
    character_entries.collect(&:render).inject(:+)
  end

  def render_match_vote_graph
    image_tag match.vote_graph_url if match.vote_graph?
  end

  def character_entries
    @character_entries ||= match.match_entries.ordered_by_votes.collect do |me|
      CharacterEntry.new(me, show_color: true, show_percentage: true, use_percentage_width: true)
    end
  end
end