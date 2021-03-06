class GroupViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :tournament, :group

  def to_partial_path
    'view_models/group'
  end

  def dependencies
    [tournament, group]
  end

  def initialize tournament, group
    @tournament = tournament
    @group = group
    self
  end

  def render_group_stages
    stages.collect.with_index do |stage, index|
      if group == :losers_playoff_single
        {
          stage: MatchInfo.pretty_stage(stage),
          linked_match: matches_for(stage).first
        }
      else
        {
          stage: MatchInfo.pretty_stage(stage),
          match_view_models: matches_for(stage).collect do |match|
            MatchViewModel.new(match, cache: :group, table_margins: index > 0)
          end
        }
      end
    end
  end

  private

  def stages
    @stages ||= MatchInfo::PLAYOFF_GROUPS.include?(group) ? (tournament.group_stages_with_playoffs_to_display || []) : tournament.group_stages_without_playoffs
  end

  def matches_for stage
    @matches ||=
      tournament
        .matches
        .group_matches
        .where(group: group)
        .ordered
        .includes(:match_entries => [:previous_match, {:appearance => {:character_role => [:character, :series]}}])
    @stage_matches ||= {}
    @stage_matches[stage] ||= @matches.where(stage: stage)
  end
end
