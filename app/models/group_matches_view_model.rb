class GroupMatchesViewModel
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
    content_tag :div, class: 'group-matches-view-model' do
      ''.tap do |outer_tag|
        groups.each do |group|
          outer_tag << group_selector(group)
          outer_tag << group_title(group)
          outer_tag << GroupViewModel.new(tournament, group).render
          outer_tag << content_tag(:div, '', class: 'cb')
          outer_tag << tag(:hr)
        end
      end.html_safe
    end
  end

  private

  def group_title current_group
    content_tag :h3 do
      content_tag :a, MatchInfo.pretty_group(current_group), name: current_group, class: 'anchor'
    end
  end

  def group_selector current_group
    content_tag :div, class: 'pagination pagination-small pagination-centered' do
      content_tag(:ul) do
        ''.tap do |outer_tag|
          outer_tag << content_tag(:li, link_to('Jump to:', '#'), class: 'disabled')
          groups.each do |group|
            state = 'active' if group == current_group
            outer_tag << content_tag(:li, link_to(MatchInfo.pretty_group(group, :short), "##{group}"), class: state)
          end
        end.html_safe
      end
    end
  end

  def groups
    @groups ||= tournament.groups
  end
end