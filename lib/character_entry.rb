class CharacterEntry
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :character, :match_entry # Can show one of these, so only one is allowed to be defined in initializer
  attr_accessor :right_align, :show_avatar, :show_series, :show_color, :show_votes, :fixed_width, :is_transparent, :fill_background

  def initialize character_or_match_entry
    if character_or_match_entry.is_a? Character
      @character = character_or_match_entry
    elsif character_or_match_entry.is_a? MatchEntry
      @match_entry = character_or_match_entry
      @character = @match_entry.character
    else
      raise ArgumentError, 'character_or_match_entry must either be a Character or a MatchEntry'
    end
    self
  end

  def right_align
    @right_align.nil? ? false : @right_align
  end
  def show_avatar
    @show_avatar.nil? ? true : @show_avatar
  end
  def show_series
    @show_series.nil? ? true : @show_series
  end
  def show_color
    @show_color.nil? ? false : @show_color
  end
  def show_votes
    @show_votes.nil? ? true : @show_votes
  end
  def fixed_width
    @fixed_width.nil? ? true : @fixed_width
  end
  def is_transparent
    @is_transparent.nil? ? false : @is_transparent
  end
  def fill_background
    @fill_background.nil? ? false : @fill_background
  end

  def render
    content_tag :div, class: main_div_class, style: main_div_style do
      ''.tap { |tag|
        tag << avatar_div if show_avatar
        tag << votes_div if show_votes
        tag << character_div
        tag << series_div if show_series
        tag << content_tag(:div, '', class: 'cb')
      }.html_safe
    end
  end

  private

  def appearance
    @appearance ||= @match_entry.appearance if @match_entry
  end

  def character_display_name
    @character_display_name ||= (@match_entry ? @match_entry.character_name : @character.full_name)
  end

  def series
    @series ||= (@match_entry ? @match_entry.series : @character.main_series)
  end

  def series_color
    return nil unless show_color
    @series_color ||= series.color_code if series
  end

  def votes
    return nil unless show_votes
    @votes ||= @match_entry.number_of_votes if @match_entry
  end

  def winner?
    @winner ||= @match_entry.is_winner? if @match_entry
  end

  def avatar_url
    @avatar_url ||= (appearance.try(:character_avatar?) ? appearance.character_avatar_url(:thumb) : @character.avatar_url(:thumb))
  end

  # Rendering

  def bright_color hex_string
    return nil unless hex_string
    rgb = hex_string.sub(/\A#/, '').scan(/../).map {|color| color.to_i(16)}
    (0.299*rgb[0] + 0.587*rgb[1] + 0.114*rgb[2]) > 100
  end

  def main_div_class
    'character_entry'.tap do |div_class|
      div_class << ' right' if right_align
      div_class << ' fixed_width' if fixed_width
      div_class << ' transparent' if is_transparent
      div_class << ' fill_background' if fill_background
      div_class << (show_series ? ' show_series' : ' hide_series')
      div_class << (show_avatar ? ' show_avatar' : ' hide_avatar')
      div_class << (bright_color(series_color) ? ' dark_text' : ' light_text') if series_color
    end
  end

  def main_div_style
    "background-color: ##{series_color};" if series_color
  end

  def avatar_div
    content_tag :div, class: 'character_image' do
      image_tag avatar_url, alt: character_display_name, size: '40x40'
    end
  end

  def votes_div
    votes_div_class = 'character_votes'
    votes_div_class << (winner? ? ' winner' : ' loser') if show_color
    content_tag :div, class: votes_div_class do
      content_tag :p, votes.to_s
    end
  end

  def character_div
    content_tag :div, class: 'character_name' do
      link_to character_display_name, character_path(character), title: character_display_name
    end
  end

  def series_div
    content_tag :div, class: 'series_name' do
      content_tag :em, link_to(series.name, series_path(series), title: series.name)
    end
  end
end




## Renders a nice box with avatar, character name, and series

#  color_code = series && series.color_code
#
#  div_class = "thumbnail character_entry"
#  div_class << " right" if options[:right_align]
#  div_class << " hide_series" unless options[:show_series]
#  div_class << " fixed_width" if options[:fixed_width]
#  div_class << " no_avatar" if options[:fixed_width] && !options[:show_avatar]
#  div_class << " fade_out" if options[:fade_out]
#  div_class << " fill_background" if options[:fill_background]
#  if options[:show_color] && color_code
#    div_class << (bright_color(color_code) ? " dark_text" : " light_text")
#    #div_class << " dark_text"
#  end
#
#  content_tag :div,
#              class: div_class,
#              style: ("background-color: ##{color_code};" if options[:show_color] && color_code) do
#    c = ""
#    if options[:show_avatar]
#      c << content_tag(:div,
#                       class: 'character_image') do
#        image_tag avatar_url,
#                  alt: display_name,
#                  size: '40x40'
#      end
#    end
#    if votes && options[:show_votes]
#      c << content_tag(:div,
#                       class: "character_votes#{(is_winner ? ' winner' : ' loser') if options[:show_color]}") do
#
#        content_tag :p, votes.to_s
#      end
#    end
#    c << content_tag(:div,
#                     class: 'character_name') do
#      link_to(display_name,
#              character_path(character),
#              title: display_name) if character
#    end
#    if options[:show_series]
#      c << content_tag(:div,
#                       class: 'series_name') do
#        content_tag(:em,
#                    link_to(series.name,
#                            series_path(series),
#                            title: series.name)) if series
#      end
#    end
#    c << content_tag(:div, '', class: 'cb')
#    c.html_safe
#  end
#end