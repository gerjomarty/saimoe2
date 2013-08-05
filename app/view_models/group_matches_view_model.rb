class GroupMatchesViewModel
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :tournament

  def to_partial_path
    'view_models/group_matches'
  end

  def initialize tournament
    @tournament = tournament
    self
  end

  def render_groups
    groups.collect do |group|
      {selector: group_selector(group),
       title: group_title(group),
       group_view_model: GroupViewModel.new(tournament, group)}
    end
  end

  private

  def group_title current_group
    content_tag :h3 do
      content_tag :a, MatchInfo.pretty_group(current_group), name: current_group.upcase, class: 'anchor'
    end
  end

  def group_selector current_group
    content_tag :div, class: 'pagination pagination-small pagination-centered' do
      content_tag(:ul) do
        ''.tap do |outer_tag|
          outer_tag << content_tag(:li, link_to('Jump to:', '#'), class: 'disabled')
          groups.each do |group|
            if MatchInfo::PLAYOFF_GROUPS.first == group
              outer_tag << content_tag(:li, link_to('Playoff groups:', '#'), class: 'disabled')
            end
            state = 'active' if group == current_group
            outer_tag << content_tag(:li, link_to(MatchInfo.pretty_group(group, :short), "##{group.upcase}"), class: state)
          end
        end.html_safe
      end
    end
  end

  def groups
    @groups ||= tournament.groups
  end
end