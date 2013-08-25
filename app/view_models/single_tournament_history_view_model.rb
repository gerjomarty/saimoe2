class SingleTournamentHistoryViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :entity, :tournament

  def to_partial_path
    'view_models/single_tournament_history'
  end

  def dependencies
    [entity, tournament]
  end

  def initialize entity, tournament
    @entity = entity
    @tournament = tournament
    self
  end

  def button_class stage
    if winning_stages.include? stage
      'btn-success'
    elsif unfinished_stages.include? stage
      'btn-warning'
    elsif losing_stages.include? stage
      'btn-danger'
    else
      'disabled'
    end
  end

  def popover_name stage
    "#{tournament.year}_#{stage}"
  end

  def participated_stages
    @participated_stages ||= entry_information.keys
  end

  def visible_stages
    @visible_stages ||= all_stages & (participated_stages | default_visible_stages)
  end

  # Only makes sense for single character situations
  def single_match_popover_view_model stage
    return nil unless entity.is_a? Character
    match = entry_information[stage].values.flatten.first[:match]
    return nil unless match
    MatchViewModel.new(match, cache: :single_tournament_history, show_percentages: true)
  end

  # Only makes sense for multiple character situations
  def multiple_matches_popover_view_model stage
    return nil if entity.is_a? Character
    WinnersLosersPopoverViewModel.new(entry_information[stage][:winner],
                                      entry_information[stage][:loser],
                                      entry_information[stage][:unfinished])
  end

  private

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

  def winning_stages
    @winning_stages ||= entry_information.select {|stage, info| info[:winner] && info[:winner].any? }.keys
  end

  def losing_stages
    @losing_stages ||= entry_information.select {|stage, info| info[:loser] && info[:loser].all? }.keys
  end

  def unfinished_stages
    @unfinished_stages ||= entry_information.select {|stage, info| info[:unfinished] && info[:unfinished].any? }.keys
  end
end