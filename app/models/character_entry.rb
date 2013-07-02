class CharacterEntry
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :character, :match_entry # Can show one of these, so only one is allowed to be defined in initializer
  attr_accessor :extra_class, :extra_style, :right_align, :show_avatar, :show_series, :show_color, :show_votes, :fixed_width, :transparency, :grey_background

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

  def with options={}
    options.each {|key, value| self.send "#{key}=".to_sym, value }
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
  def transparency
    @transparency.nil? ? false : @transparency
  end
  def transparency= strategy
    allowed_values = [true, false, :all_but_winner]
    raise ArgumentError, "transparency must be one of #{allowed_values.inspect}" unless allowed_values.include?(strategy)
    @transparency = strategy
  end
  def grey_background
    @grey_background.nil? ? false : @grey_background
  end

  def render
    # content_tag :div, class: extra_class, style: extra_style do
      content_tag :div, class: main_div_class, style: main_div_style do
        ''.tap do |tag|
          tag << avatar_div if show_avatar
          tag << votes_div if show_votes && votes
          tag << character_div
          tag << series_div if show_series
          tag << content_tag(:div, '', class: 'cb')
        end.html_safe
      end
    # end
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
    red, green, blue = hex_string.sub(/\A#/, '').scan(/../).map {|color| color.to_i(16)}
    (0.299*red + 0.587*green + 0.114*blue) > 100
  end

  def main_div_class
    'character_entry'.tap do |div_class|
      div_class << ' right' if right_align
      div_class << ' fixed_width' if fixed_width
      div_class << ' transparent' if should_make_transparent?
      div_class << ' grey_background' if grey_background
      div_class << ' hide_series' unless show_series && series
      div_class << ' hide_avatar' unless show_avatar
      div_class << (bright_color(series_color) ? ' dark_text' : ' light_text') if series_color
    end
  end

  def main_div_style
    "background-color: ##{series_color};" if series_color
  end

  def avatar_div
    content_tag :div, class: 'character_image' do
      image_tag avatar_url, alt: character_display_name
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

  def should_make_transparent?
    if transparency == :all_but_winner
      !winner?
    else
      transparency
    end
  end
end