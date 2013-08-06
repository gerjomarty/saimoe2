class TournamentViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :tournament

  def to_partial_path
    'view_models/tournament'
  end

  def dependencies
    [tournament]
  end

  def initialize tournament
    @tournament = tournament
    self
  end

  def final_matches_view_model
    FinalMatchesViewModel.new(tournament)
  end

  def group_matches_view_model
    GroupMatchesViewModel.new(tournament)
  end
end