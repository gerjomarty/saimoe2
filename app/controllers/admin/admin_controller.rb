require 'csv'
require 'digest/sha2'
require 'erb'
require 'ostruct'

class Template < OpenStruct
  def render template
    ERB.new(template).result(binding)
  end
end

class Admin::AdminController < ApplicationController
  include ApplicationHelper
  REALM = ENV['APP_REALM']
  USERS = {ENV['APP_USERNAME'] => ENV['APP_PASSWORD_HASH']}

  USE_CHARACTER_ARR_SERIES_REGEXP = /Pretty Cure/

  force_ssl
  before_filter :authenticate

  def clear_cache
    if Rails.cache.clear
      render text: "Cache cleared", status: :ok
    else
      render text: "Problem when clearing cache", status: :internal_server_error
    end
  end

  def utilities
    unless (info = params && params[:info])
      render
      return
    end

    character_arr = series_arr = nil
    character_string, series_string = info[:character_csv].read, info[:series_csv].read

    begin
      character_string = character_string.force_encoding('SHIFT_JIS').encode('UTF-8', undef: :replace)
    rescue Encoding::InvalidByteSequenceError
      character_string = character_string.force_encoding('UTF-8')
    end
    begin
      series_string = series_string.force_encoding('SHIFT_JIS').encode('UTF-8', undef: :replace)
    rescue Encoding::InvalidByteSequenceError
      series_string = series_string.force_encoding('UTF-8')
    end

    begin
      c_done = false
      character_arr = CSV.parse(character_string)
      c_done = true
      series_arr = CSV.parse(series_string)
    rescue CSV::MalformedCSVError => e
      flash[:alert] = "Malformed CSV input in #{c_done ? 'series' : 'characters'} file: #{e}"
      return
    end

    character_arr.collect! do |i|
      i.collect { |ii|
        stripped = ii.try(:strip).try(:chomp).try(:strip)
        stripped && stripped.empty? ? nil : stripped
      }.reverse.drop_while {|ii| ii.nil? }.reverse.to_a # Remove trailing nils
    end
    series_arr.collect! do |i|
      i.collect { |ii|
        stripped = ii.try(:strip).try(:chomp).try(:strip)
        stripped && stripped.empty? ? nil : stripped
      }.reverse.drop_while {|ii| ii.nil? }.reverse.to_a # Remove trailing nils
    end
    character_arr.collect! {|i| i && i.empty? ? nil : i}
    series_arr.collect! {|i| i && i.empty? ? nil : i}
    character_arr.compact!
    series_arr.compact!

    unless (char_incorrect = character_arr.select {|i| i.size < 2 }) && char_incorrect.empty?
      flash[:alert] = "Some lines in character CSV not in correct format: #{char_incorrect.inspect}"
      return
    end
    unless (series_incorrect = series_arr.select {|i| i.size < 2 }) && series_incorrect.empty?
      flash[:alert] = "Some lines in series CSV not in correct formar: #{series_incorrect.inspect}"
      return
    end

    # Add SERIES on to the end of character - should now have 8 entries per row
    curr_series = nil
    character_arr.collect! do |i|
      if i[0] == 'SERIES'
        curr_series = i[1]
        nil
      else
        i + [curr_series]
      end
    end
    character_arr.compact!

    character_arr.sort_by! do |_, e_name, _, _, _, _, _, _|
      split_name = e_name.try(:split, / /)
      if split_name.nil? || split_name.size == 1
        [e_name || '']
      else
        [split_name.last, e_name || '']
      end
    end
    series_arr.sort_by! {|_, e_series, _, _| [e_series]}

    if info[:transform] == 'name_list'

      order_by_name = (info[:name_order_by_name] == '1')

      name_string = info[:name_csv].read
      begin
        name_string = name_string.force_encoding('SHIFT_JIS').encode('UTF-8', undef: :replace)
      rescue Encoding::InvalidByteSequenceError
        name_string = name_string.force_encoding('UTF-8')
      end
      name_arr = name_string.lines.to_a.collect {|l| l.try(:strip).try(:chomp).try(:strip)}.compact
      name_arr.collect! {|l| l && l.empty? ? nil : l}
      name_arr.compact!

      @split_names = [[]].tap {|sr|
        name_arr.collect {|str|
          if (match = /\A(?:[^\p{Space}]+\p{Space})(?:<<)?(.*?)\uff20(.*?)(?:>>)?\Z/.match(str))
            match.to_a.collect(&:strip)
          else
            ''
          end
        }.collect {|id_string, id_name, id_series|
          char_index = character_arr.index {|j_name, _, _, _, _, _, _, _| j_name == id_name} if id_name
          series_index = series_arr.index {|j_series, _, _, _| j_series == id_series} if id_series
          j_name, e_name, char_code, va, va_code, prelim_rank, prev_best = nil
          j_name, e_name, char_code, va, va_code, prelim_rank, prev_best, _ = character_arr[char_index] if char_index
          j_series, e_series, series_color, series_code = nil
          j_series, e_series, series_color, series_code = series_arr[series_index] if series_index
          if e_series && char_index && e_series =~ USE_CHARACTER_ARR_SERIES_REGEXP
            e_series = character_arr[char_index].last
            series_index = series_arr.index {|_, e_s, _, _| e_s == e_series }
            if series_index
              _, _, series_color, series_code = series_arr[series_index]
            end
          end
          [id_string, j_name, e_name, j_series, e_series, char_code, va, va_code, prelim_rank, prev_best, series_color, series_code]
        }.each {|result|
          if result[0].present?
            sr[-1] << result
          else
            sr << [] unless sr[-1].empty?
          end
        }
      }

      if order_by_name
        @split_names.collect! do |results|
          results.sort_by do |_, _, e_name, _, e_series, _, _, _, _, _, _, _|
            split_name = e_name.try(:split, / /)
            if split_name.nil? || split_name.size == 1
              [(e_name.nil? || e_series.nil?) ? 0 : 1, e_series || '', e_name || '']
            else
              [(e_name.nil? || e_series.nil?) ? 0 : 1, e_series || '', split_name.last, e_name || '']
            end
          end
        end
      end

      name_list = @split_names.collect {|r|
        r.collect {|id_string, j_name, e_name, j_series, e_series, _, _, _, _, _, _, _|
          "#{e_name || '???'} @ #{e_series || '???'}: #{j_name && j_series ? %Q|<<#{j_name}\uff20#{j_series}>>| : id_string}"
        }.join("<br />\r\n")
      }.join("<br /><br />\r\n\r\n")

      template_names = @split_names.collect do |s_result|
        s_result.collect do |_, j_name, e_name, j_series, e_series, char_code, va, va_code, prelim_rank, prev_best, series_color, series_code|
          {name: e_name || j_name,
           series: e_series || j_series,
           character_code: char_code,
           voice_actor: va,
           voice_actor_code: va_code,
           preliminary_rank: prelim_rank,
           previous_best: prev_best,
           series_color: series_color,
           series_code: series_code}
        end
      end

      if info[:name_round_1_matches] == '1'
        template = Template.new(names: template_names, result_list: name_list)
                           .render(File.read(Rails.root.join('lib', 'templates', 'round_1_matches.html.erb')))
      else
        template = Template.new(result_list: name_list)
                           .render(File.read(Rails.root.join('lib', 'templates', 'result_list.html.erb')))
      end

      send_data template, filename: "html_template_#{Time.zone.now.to_s.gsub(/ /, '_')}.html"

    elsif info[:transform] == 'result_list'

      show_percent = (info[:result_show_percent] == '1')

      result_string = info[:result_csv].read
      begin
        result_string = result_string.force_encoding('Shift_JIS').encode('UTF-8', undef: :replace)
      rescue Encoding::InvalidByteSequenceError
        result_string = result_string.force_encoding('UTF-8')
      end
      result_arr = result_string.lines.to_a.collect {|l| l.try(:strip).try(:chomp).try(:strip)}.compact
      result_arr.collect! {|l| l && l.empty? ? nil : l}
      result_arr.compact!

      @split_results = [[]].tap { |sr|
        result_arr.collect {|str|
          if (match = /\A(\p{Digit}+)\p{Alpha}+\p{Space}+(\p{Digit}+)\p{Alpha}+\p{Space}+(.*?)\uff20(.*?)\Z/.match(str))
            match.to_a.collect(&:strip)
          else
            ''
          end
        }.collect {|res_string, place, votes, res_name, res_series|
          char_index = character_arr.index {|j_name, _, _, _, _, _, _, _| j_name == res_name} if res_name
          series_index = series_arr.index {|j_series, _, _, _| j_series == res_series} if res_series
          j_name, e_name, char_code, va, va_code, prelim_rank, prev_best = nil
          j_name, e_name, char_code, va, va_code, prelim_rank, prev_best, _ = character_arr[char_index] if char_index
          j_series, e_series, series_color, series_code = nil
          j_series, e_series, series_color, series_code = series_arr[series_index] if series_index
          if e_series && char_index && e_series =~ USE_CHARACTER_ARR_SERIES_REGEXP
            e_series = character_arr[char_index].last
            series_index = series_arr.index {|_, e_s, _, _| e_s == e_series }
            if series_index
              _, _, series_color, series_code = series_arr[series_index]
            end
          end
          [res_string, place.to_i, votes.to_i, j_name, e_name, j_series, e_series, char_code, va, va_code, prelim_rank, prev_best, series_color, series_code]
        }.each {|result|
          if result[0].present?
            sr[-1] << result
          else
            sr << [] unless sr[-1].empty?
          end
        }
      }.collect {|result|
        result.sort_by {|_, place, votes, _, e_name, _, e_series, _, _, _, _, _, _, _|
          split_name = e_name.try(:split, / /)
          if split_name.nil? || split_name.size == 1
            [place, -votes, e_series || '', e_name || '']
          else
            [place, -votes, e_series || '', split_name.last]
          end
        }
      }

      result_list = @split_results.collect do |r|
        total_votes = 0
        r.each {|_, _, votes, _, _, _, _, _, _, _, _, _, _, _| total_votes += votes}

        r.collect {|res_string, place, votes, j_name, e_name, j_series, e_series, _, _, _, _, _, _, _|
          vote_share = votes.to_f / total_votes.to_f
          str = "#{place.ordinalize} #{votes} #{'(' + format_percent(vote_share) + ') ' if show_percent}#{e_name || '???'} @ #{e_series || '???'}"
          if e_name && e_series
            str
          else
            str << " #{res_string}"
          end
        }.join("<br />\r\n")
      end.join("<br /><br />\r\n\r\n")

      template_results = @split_results.collect do |s_result|
        s_result.collect do |_, place, votes, j_name, e_name, j_series, e_series, char_code, va, va_code, prelim_rank, prev_best, series_color, series_code|
          {ranking: place.ordinalize,
           vote_count: votes,
           name: e_name || j_name,
           series: e_series || j_series,
           character_code: char_code,
           voice_actor: va,
           voice_actor_code: va_code,
           preliminary_rank: prelim_rank,
           previous_best: prev_best,
           series_color: series_color,
           series_code: series_code}
        end
      end

      if info[:result_first_prelim] == '1'
        template = Template.new(results: template_results[0], result_list: result_list)
                           .render(File.read(Rails.root.join('lib', 'templates', 'first_prelim.html.erb')))
      elsif info[:result_second_prelim] == '1'
        template = Template.new(results: template_results[0], result_list: result_list)
                           .render(File.read(Rails.root.join('lib', 'templates', 'second_prelim.html.erb')))
      else
        template = Template.new(result_list: result_list)
                           .render(File.read(Rails.root.join('lib', 'templates', 'result_list.html.erb')))
      end

      send_data template, filename: "html_template_#{Time.zone.now.to_s.gsub(/ /, '_')}.html"
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic(REALM) do |username, password|
      USERS[username] && USERS[username] == hash_password(username, password)
    end
  end

  def hash_password username, password
    Digest::SHA2.hexdigest([username, REALM, password].join(':'))
  end
end
