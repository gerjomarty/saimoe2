class TournamentHistoryViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :entity

  def to_partial_path
    'view_models/tournament_history'
  end

  def dependencies
    [entity]
  end

  def initialize entity
    @entity = entity
    self
  end

  def single_tournament_view_models
    @single_tournament_view_models ||= tournaments.collect do |t|
      SingleTournamentHistoryViewModel.new(entity, t)
    end
  end

  private

  def tournaments
    @tournaments ||= entity.tournaments.ordered
  end
end