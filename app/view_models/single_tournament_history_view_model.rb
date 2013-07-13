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
    content_tag(:div, class: 'btn-group') do
      visible_stages.collect do |stage|
        content_tag(:button, class: "btn #{button_class(stage)}", rel: "html_named_popover_#{tournament.year}_#{stage}", data: {trigger: 'hover click', placement: :top, container: :body}) do
          MatchInfo.pretty_stage(stage)
        end
      end.inject(:+)
    end +
    participated_stages.collect do |stage|
      content_tag(:div, rel: "html_named_popover_#{tournament.year}_#{stage}_content") { popover_content(stage) }
    end.inject(:+)
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

  def popover_content stage
    if entity.is_a? Character
      single_match_popover_content stage
    else
      multiple_matches_popover_content stage
    end
  end

  def single_match_popover_content stage
    match = entry_information[stage].values.flatten.first[:match]
    return nil unless match
    MatchViewModel.new(match, show_percentages: true).render
  end

  def multiple_matches_popover_content stage
    WinnersLosersPopoverViewModel.new(entry_information[stage][:winner],
                                      entry_information[stage][:loser],
                                      entry_information[stage][:unfinished]).render
  end

  # Common to tournament

  def all_stages
    @all_stages ||= tournament.stages
  end

  def default_visible_stages
    @default_visible_stages ||= all_stages - MatchInfo::PLAYOFF_STAGES
  end

  # Common to entity

  def entry_information
    @entry_information ||= {}.tap do |hash|
      entity.match_entries.includes(:match => :match_entries).merge(Match.ordered).where(matches: {tournament_id: tournament}).each do |me|
        hash[me.match.stage] ||= {}
        hash[me.match.stage][entry_state(me)] ||= []
        hash[me.match.stage][entry_state(me)] << {match: me.match, match_entry: me}
      end
    end
  end

  def entry_state match_entry
    if match_entry.is_finished?
      if match_entry.is_winner?
        :winner
      else
        :loser
      end
    else
      :unfinished
    end
  end

  # These methods apply to both button state and match state for entities with one match entry per stage
  # However, these methods only apply to button state when there are multiple match entries per stage
  # Therefore, don't rely on these methods to decide logic for individual matches in this case

  def participated_stages
    @participated_stages ||= entry_information.keys
  end

  def winning_stages
    @winning_stages ||= entry_information.select {|stage, info| info[:winner] && info[:winner].any? }.keys
  end

  def losing_stages
    @losing_stages ||= entry_information.select {|stage, info| info[:loser] && info[:loser].all? }.keys
  end

  def unfinished_stages
    @unfinished_stages ||= entry_information.select {|stage, info| info[:unfinished] && info[:unfinished].any? }.keys
  end

  def visible_stages
    @visible_stages ||= all_stages & (participated_stages | default_visible_stages)
  end
end