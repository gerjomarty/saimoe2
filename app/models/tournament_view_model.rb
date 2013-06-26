class TournamentViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :tournament

  def initialize tournament
    @tournament = tournament
    self
  end

  def render
    content_tag :div, class: 'tournament-view-model' do
      ''.tap do |outer_tag|
        if final_matches_div
          outer_tag << final_matches_div
          outer_tag << content_tag(:div, '', class: 'cb')
          outer_tag << tag(:hr)
        end
        outer_tag << group_matches_div
      end.html_safe
    end
  end

  private

  def final_matches_div
    if (fmvm = FinalMatchesViewModel.new(tournament)).visible?
      fmvm.render
    else
      nil
    end
  end

  def group_matches_div
    GroupMatchesViewModel.new(tournament).render
  end
end