class FinalMatchesViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :tournament

  def to_partial_path
    'view_models/final_matches'
  end

  def dependencies
    [tournament]
  end

  def initialize tournament
    @tournament = tournament
    self
  end

  def visible?
    matches.any?
  end

  def grand_final_view_model
    MatchViewModel.new(final_match, cache: :final_matches, match_name: :long, info_position: :bottom)
  end

  def left_quarter_final_view_models
    quarter_final_matches[0..1].collect do |match|
      MatchViewModel.new(match, cache: :final_matches, match_name: :short)
    end
  end

  def left_semi_final_view_model
    MatchViewModel.new(semi_final_matches[0], cache: :final_matches, match_name: :short)
  end

  def right_semi_final_view_model
    MatchViewModel.new(semi_final_matches[1], cache: :final_matches, match_name: :short, info_position: :left)
  end

  def right_quarter_final_view_models
    quarter_final_matches[2..3].collect do |match|
      MatchViewModel.new(match, cache: :final_matches, match_name: :short, info_position: :left)
    end
  end

  def last_16_view_models
    last_16_matches.collect do |match|
      MatchViewModel.new(match, cache: :final_matches, match_name: :short)
    end.each_slice(2)
  end

  def victory_image_tag
    %w{png jpg jpeg}.each do |ext|
      path = "victory-images/#{tournament.year}.#{ext}"
      return image_tag(path) if Rails.application.assets.find_asset path
    end
    nil
  end

  private

  def matches
    @matches ||=
      tournament
        .matches
        .final_matches
        .ordered
        .includes(:match_entries => {:appearance => {:character_role => [:character, :series]}})
  end

  def final_match
    @final_match ||= matches.select {|m| m.stage == :final}.first
  end

  def semi_final_matches
    @semi_final_matches ||= matches.select {|m| m.stage == :semi_final}
  end

  def quarter_final_matches
    @quarter_final_matches ||= matches.select {|m| m.stage == :quarter_final}
  end

  def last_16_matches
    @last_16_matches ||= matches.select {|m| m.stage == :last_16}
  end
end