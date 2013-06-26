class FinalMatchesViewModel
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
    content_tag :div, class: 'final-matches-view-model' do
      ''.tap do |outer_tag|
        if show_victory_image?
          outer_tag << victory_image_div
          outer_tag << tag(:hr)
        end
        outer_tag << grand_final_div
        outer_tag << content_tag(:div, '', class: 'cb')
        outer_tag << left_quarter_final_div
        outer_tag << left_semi_final_div
        outer_tag << right_semi_final_div
        outer_tag << right_quarter_final_div
        outer_tag << content_tag(:div, '', class: 'cb')
        if show_last_16?
          outer_tag << tag(:hr)
          outer_tag << content_tag(:h3, MatchInfo.pretty_stage(:last_16))
          outer_tag << last_16_div
        end
      end.html_safe
    end
  end

  def visible?
    matches.any?
  end

  private

  def victory_image_tag
    %w{png jpg jpeg}.each do |ext|
      path = "victory-images/#{tournament.year}.#{ext}"
      return image_tag(path) if Rails.application.assets.find_asset path
    end
    nil
  end

  def show_victory_image?
    victory_image_tag.present?
  end

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

  def show_last_16?
    matches.any? {|m| m.stage == :last_16}
  end

  # Rendering

  def victory_image_div
    content_tag :div, class: 'victory-image' do
      victory_image_tag
    end
  end

  def grand_final_div
    content_tag :div, class: 'final' do
      MatchViewModel.new(final_match, match_name: :long, info_position: :bottom).render
    end
  end

  def left_quarter_final_div
    content_tag :div, class: 'quarter-final left' do
      ''.tap do |outer_tag|
        outer_tag << MatchViewModel.new(quarter_final_matches[0], match_name: :short).render
        outer_tag << content_tag(:div, '', class: 'cb')
        outer_tag << MatchViewModel.new(quarter_final_matches[1], match_name: :short).render
      end.html_safe
    end
  end

  def left_semi_final_div
    content_tag :div, class: 'semi-final left' do
      MatchViewModel.new(semi_final_matches[0], match_name: :short).render
    end
  end

  def right_semi_final_div
    content_tag :div, class: 'semi-final right' do
      MatchViewModel.new(semi_final_matches[1], match_name: :short, info_position: :left).render
    end
  end

  def right_quarter_final_div
    content_tag :div, class: 'quarter-final right' do
      ''.tap do |outer_tag|
        outer_tag << MatchViewModel.new(quarter_final_matches[2], match_name: :short, info_position: :left).render
        outer_tag << content_tag(:div, '', class: 'cb')
        outer_tag << MatchViewModel.new(quarter_final_matches[3], match_name: :short, info_position: :left).render
      end.html_safe
    end
  end

  def last_16_div
    content_tag :div, class: 'last-16' do
      ''.tap do |outer_tag|
        last_16_matches.each_slice(2) do |top_match, bottom_match|
          outer_tag << content_tag(:div, class: 'last-16-block') do
            ''.tap do |inner_tag|
              inner_tag << MatchViewModel.new(top_match, match_name: :short).render
              inner_tag << content_tag(:div, '', class: 'cb')
              inner_tag << MatchViewModel.new(bottom_match, match_name: :short).render
            end.html_safe
          end
        end
      end.html_safe
    end
  end
end