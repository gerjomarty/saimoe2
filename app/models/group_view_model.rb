class GroupViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :tournament, :group

  def initialize tournament, group
    @tournament = tournament
    @group = group
    self
  end

  def render
    content_tag(:div, class: 'group-view-model') do
      ''.tap do |outer_tag|
        stages.each.with_index do |stage, index|
          outer_tag << content_tag(:div, class: 'group-view-model-stage') do
            ''.tap do |stage_tag|
              stage_tag << content_tag(:h4, MatchInfo.pretty_stage(stage))
              stage_tag << content_tag(:div, '', class: 'cb')
              matches_for(stage).each do |match|
                stage_tag << MatchViewModel.new(match, table_margins: index > 0).render
                stage_tag << content_tag(:div, '', class: 'cb')
              end
            end.html_safe
          end
        end
      end.html_safe
    end
  end

  private

  def stages
    @stages ||= tournament.group_stages_without_playoffs
  end

  def matches_for stage
    @matches ||=
      tournament
        .matches
        .group_matches.without_playoffs.where(group: group)
        .ordered
        .includes(:match_entries => [:previous_match, {:appearance => {:character_role => [:character, :series]}}])
    @stage_matches ||= {}
    @stage_matches[stage] ||= @matches.where(stage: stage)
  end
end