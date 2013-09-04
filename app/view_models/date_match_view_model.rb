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
  attr_accessor :percentage_width_max_votes, :percentage_width_min_votes

  def to_partial_path
    'view_models/date_match'
  end

  def dependencies
    [match]
  end

  def initialize match, options={}
    @match = match
    options.each {|key, value| self.send "#{key}=".to_sym, value }
    self
  end

  def render_title
    votes = if match.number_of_votes
              content_tag(:small, "(#{pluralize(match.number_of_votes, 'vote')} total)")
            else
              ''
            end
    content_tag(:h3) do
      (match.pretty + ' ' + votes).html_safe
    end
  end

  def character_entries
    @character_entries ||= match.match_entries.ordered_by_votes.collect do |me|
      CharacterEntry.new(me, cache: :date_match, show_color: true, show_percentage: true, use_percentage_width: true, percentage_width_max_votes: percentage_width_max_votes, percentage_width_min_votes: percentage_width_min_votes)
    end
  end
end