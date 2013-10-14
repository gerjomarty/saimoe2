class CharacterEntry
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  include ApplicationHelper

  attr_reader :character, :match_entry # Can show one of these, so only one is allowed to be defined in initializer
  attr_accessor :cache, :extra_class, :extra_style, :right_align, :show_avatar, :show_series, :show_color, :show_votes, :show_percentage, :fixed_width, :use_percentage_width, :percentage_width_max_votes, :percentage_width_min_votes, :transparency, :grey_background, :schema_markup

  def to_partial_path
    'view_models/character_entry'
  end

  def dependencies
    [character,
      match_entry,
      match_entry.try(:match).try(:next_match_entries).try(:first),
      match_entry.try(:match).try(:next_match_entries).try(:first).try(:match).try(:next_match_entries).try(:first),
      match_entry.try(:match).try(:next_match_entries).try(:first).try(:match).try(:next_match_entries).try(:first).try(:match).try(:next_match_entries).try(:first),
      cache].compact
  end

  def initialize character_or_match_entry, options={}
    if character_or_match_entry.is_a? Character
      @character = character_or_match_entry
    elsif character_or_match_entry.is_a? MatchEntry
      @match_entry = character_or_match_entry
      @character = @match_entry.character
    else
      raise ArgumentError, 'character_or_match_entry must either be a Character or a MatchEntry'
    end
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
  def show_percentage
    @show_percentage.nil? ? false : @show_percentage
  end
  def fixed_width
    @fixed_width.nil? ? true : @fixed_width
  end
  def use_percentage_width
    @use_percentage_width.nil? ? false : @use_percentage_width
  end
  def transparency
    @transparency.nil? ? false : @transparency
  end
  def transparency= strategy
    allowed_values = [true, false, :all_but_winner, :non_losers_playoff_entries]
    raise ArgumentError, "transparency must be one of #{allowed_values.inspect}" unless allowed_values.include?(strategy)
    @transparency = strategy
  end
  def grey_background
    @grey_background.nil? ? false : @grey_background
  end
  def schema_markup
    @schema_markup.nil? ? false : @schema_markup
  end

  def main_div_class
    'character_entry'.tap do |div_class|
      div_class << ' right' if right_align
      div_class << ' fixed_width' if fixed_width
      div_class << ' transparent' if should_make_transparent?
      div_class << ' grey_background' if grey_background
      div_class << ' hide_series' unless show_series && series
      div_class << ' hide_avatar' unless show_avatar
      div_class << ' percentage_width' if percentage_width
      div_class << (bright_color(series_color) ? ' dark_text' : ' light_text') if series_color
    end
  end

  def main_div_style
    [].tap do |style|
      style << "background-color: ##{series_color};" if series_color
      style << "width: #{percentage_width}%;" if percentage_width
    end.join(' ')
  end

  def avatar_div
    return '' unless show_avatar
    content_tag :div, class: 'character_image' do
      options = {}.tap do |o|
        o.merge!(title: character_display_name)
        o.merge!(itemprop: :image) if schema_markup
      end
      image_tag avatar_url, options
    end
  end

  def stats_div
    return '' unless (show_votes && votes) || (show_percentage && formatted_percentage)
    content = [votes, formatted_percentage].compact
    div_class = 'character_votes'
    div_class << (winner? ? ' winner' : ' loser') if show_color
    content_tag :div, class: div_class do
      content_tag :span, class: ('two-lines' if content.size == 2) do
        ''.tap do |span_tag|
          span_tag << content_tag(:p, content[0])
          if content[1]
            span_tag << tag(:br)
            span_tag << content_tag(:span, content[1])
          end
        end.html_safe
      end
    end
  end

  def character_div
    content_tag :div, class: 'character_name' do
      if character && character_display_name
        link_options = {}.tap do |o|
          o.merge!(title: character_display_name)
          o.merge!(itemprop: :url) if schema_markup
        end
        span_options = {}.tap do |o|
          o.merge!(itemprop: :name) if schema_markup
        end
        link_to(character_path(character), link_options) do
          content_tag(:span, span_options) { character_display_name }
        end
      elsif previous_match
        text = "Winner of #{previous_match.pretty(:short)}"
        span_options = {}.tap do |o|
          o.merge!(title: text)
          o.merge!(itemprop: :name) if schema_markup
        end
        content_tag(:span, span_options) { text }
      else
        text = "#{match_entry.match.pretty(:short)} Entry #{match_entry.position}"
        span_options = {}.tap do |o|
          o.merge!(title: text)
          o.merge!(itemprop: :name) if schema_markup
        end
        content_tag(:span, span_options) { text }
      end
    end
  end

  def series_div
    return '' unless show_series && series
    content_tag :div, class: 'series_name' do
      content_tag(:em, link_to(series.name, series_path(series), title: series.name)) if series
    end
  end

  private

  def appearance
    @appearance ||= match_entry.appearance if match_entry
  end

  def previous_match
    @previous_match ||= match_entry.previous_match if match_entry
  end

  def character_display_name
    return @character_display_name if @character_display_name

    if match_entry && match_entry.character_name
      @character_display_name = match_entry.character_name
    elsif character
      @character_display_name = character.full_name
    else
      @character_display_name = nil
    end
  end

  def series
    return @series if @series

    if match_entry && match_entry.series
      @series = match_entry.series
    elsif character
      @series = character.main_series
    else
      @series = nil
    end
  end

  def series_color
    return nil unless show_color
    @series_color ||= series.color_code if series
    @series_color ||= 'D3D3D3'
  end

  def votes
    return nil unless show_votes
    @votes ||= match_entry.number_of_votes if match_entry
  end

  def vote_share
    @vote_share ||= match_entry.vote_share if match_entry
  end

  def formatted_percentage
    return nil unless show_percentage
    @formatted_percentage ||= format_percent(vote_share) if vote_share
  end

  def percentage_width
    return nil unless use_percentage_width
    return @percentage_width unless @percentage_width.nil?
    if votes && percentage_width_max_votes && percentage_width_min_votes
      min_percentage = 50
      max_percentage = 100

      left_span = percentage_width_max_votes - percentage_width_min_votes
      right_span = max_percentage - min_percentage

      scaled_votes = (votes - percentage_width_min_votes).to_f / left_span.to_f
      @percentage_width = min_percentage + scaled_votes * right_span
    else
      @percentage_width = ([100 * vote_share + 50, 100].min) if vote_share
    end
  end

  def winner?
    @winner ||= match_entry.is_winner? if match_entry
  end

  def avatar_url
    return @avatar_url if @avatar_url

    if appearance && appearance.character_avatar?
      @avatar_url = appearance.character_avatar_url(:thumb)
    elsif character
      @avatar_url = character.avatar_url(:thumb)
    else
      @avatar_url = image_path('avatar-defaults/default-thumb.png')
    end
  end

  # Rendering

  def should_make_transparent?
    if transparency == true || transparency == false
      transparency
    elsif !match_entry.is_finished?
      false
    elsif transparency == :all_but_winner
      !winner?
    elsif transparency == :non_losers_playoff_entries
      current_me = match_entry
      winning_mes = match_entry.match.match_entries.select(&:is_winner?)
      while current_me.match.next_match_entries.first.match.group_match? && !current_me.match.next_match_entries.first.match.match_entries.select(&:is_winner).empty? do
        winning_mes = current_me.match.next_match_entries.first.match.match_entries.select(&:is_winner)
        current_me = winning_mes.first
      end
      winning_appearances = winning_mes.collect(&:appearance)

      if !(Array(match_entry.try(:match).try(:winning_match_entries)).collect(&:appearance) & winning_appearances).empty? &&
        match_entry.match.match_entries.ordered_by_votes.with_rank.select {|r| r[:rank] == '1' || r[:rank] == '2' }.include?(match_entry)
        false
      else
        true
      end
    end
  end
end
