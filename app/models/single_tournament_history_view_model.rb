class SingleTournamentHistoryViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :entity, :tournament

  def initialize entity, tournament
    @entity = entity
    @tournament = tournament
    self
  end

  def render
    content_tag :div, class: 'single-tournament-history-view-model' do
      content_tag(:dt) { tournament.year } +
      content_tag(:dd) { render_stage_buttons }
    end
  end

  private

  # Rendering

  def render_stage_buttons
    content_tag :div, class: 'btn-group' do
      visible_stages.collect do |stage|
        content_tag(:button, class: "btn #{button_class(stage)}") { MatchInfo.pretty_stage(stage) }
      end.inject(:+)
    end
  end

  def button_class stage
    if winning_stages.include? stage
      'btn-success'
    elsif losing_stages.include? stage
      'btn-danger'
    elsif unfinished_stages.include? stage
      'btn-warning'
    else
      'disabled'
    end
  end

  # Common to tournament

  def all_stages
    @all_stages ||= tournament.stages
  end

  def default_visible_stages
    @default_visible_stages ||= all_stages - MatchInfo::PLAYOFF_STAGES
  end

  # Common to entity

  def match_entries
    @match_entries ||= entity.match_entries.includes(:match => :match_entries).where(matches: {tournament_id: tournament})
  end

  def participated_stages
    @participated_stages ||= match_entries.collect {|me| me.match.stage }.uniq
  end

  def winning_stages
    @winning_stages ||= match_entries.select {|me| me.is_winner? }.collect {|me| me.match.stage }.uniq
  end

  def losing_stages
    @losing_stages ||= match_entries.select {|me| me.is_finished? }.collect {|me| me.match.stage }.uniq - winning_stages
  end

  def unfinished_stages
    @unfinished_stages ||= participated_stages - winning_stages - losing_stages
  end

  def visible_stages
    @visible_stages ||= all_stages & (participated_stages | default_visible_stages)
  end
end