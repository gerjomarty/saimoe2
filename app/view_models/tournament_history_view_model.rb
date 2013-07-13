class TournamentHistoryViewModel
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
    content_tag :dl, class: 'dl-horizontal' do
      tournaments.collect do |tournament|
        SingleTournamentHistoryViewModel.new(entity, tournament).render
      end.inject(:+)
    end
  end

  private

  def tournaments
    @tournaments ||= entity.tournaments.ordered
  end
end