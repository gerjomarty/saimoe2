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

  def initialize tournament, group
    @tournament = tournament
    @group = group
    self
  end

  def render_group_stages
    stages.collect.with_index do |stage, index|
      {
        stage: MatchInfo.pretty_stage(stage),
        match_view_models: matches_for(stage).collect do |match|
          MatchViewModel.new(match, table_margins: index > 0)
        end
      }
    end
  end

  private

  def stages
    @stages ||= MatchInfo::PLAYOFF_GROUPS.include?(group) ? MatchInfo::PLAYOFF_GROUP_STAGES : tournament.group_stages_without_playoffs
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