require 'csv'

class Admin::AdminController < ApplicationController
  include ApplicationHelper
  USERNAME = ENV['APP_USERNAME']
  PASSWORD = ENV['APP_PASSWORD']

  http_basic_authenticate_with name: USERNAME, password: PASSWORD
  force_ssl

  def utilities
    if (info = params && params[:info])

      @alert = ''
      character_arr = nil
      series_arr = nil
      begin
        character_arr = CSV.parse(info[:character_csv]).collect {|i| i.collect {|ii| ii.strip.chomp.strip}}
        series_arr = CSV.parse(info[:series_csv]).collect {|i| i.collect {|ii| ii.strip.chomp.strip}}
      rescue CSV::MalformedCSVError => e
        @alert = "Malformed CSV input: #{e}"
        return
      end

      unless character_arr.all? {|i| i.size == 2} || series_arr.all? {|i| i.size == 2}
        @alert = "Some lines not in correct format: #{(character_arr + series_arr).select {|i| i.size != 2}.inspect}"
        return
      end

      character_arr.sort_by! {|_, e_name| [e_name.split(/ /).last, e_name]}
      series_arr.sort_by! {|_, e_series| [e_series]}

      if info[:transform] == 'name_list'

        name_arr = info[:name_csv].lines.to_a.collect {|l| l.strip.chomp.strip}

        @result = name_arr.collect {|str|
          /\A<<(.*?)[@\uff20](.*?)>>\Z/.match(str).to_a.collect(&:strip)
        }.collect {|id_string, id_name, id_series|
          char_index = character_arr.index {|j_name, _| j_name == id_name}
          series_index = series_arr.index {|j_series, _| j_series == id_series}
          unless char_index && series_index
            @alert = "Couldn't find #{char_index ? 'series' : 'character'} transliteration for '#{id_string}'"
            return
          end
          [char_index, series_index]
        }.sort_by {|char_index, series_index|
          [series_index, char_index]
        }.collect {|char_index, series_index|
          j_name, e_name = character_arr[char_index]
          j_series, e_series = series_arr[series_index]
          "#{e_name} @ #{e_series}: &lt;&lt;#{j_name}\uff20#{j_series}&gt;&gt;"
        }.join('<br />').html_safe

      elsif info[:transform] == 'result_list'

        result_arr = info[:result_csv].lines.to_a.collect {|l| l.strip.chomp.strip}

        total_votes = 0
        @result = result_arr.collect {|str|
          /\A(\p{Digit}+)\p{Alpha}+\p{Space}+(\p{Digit}+)\p{Alpha}+\p{Space}+(.*?)[@\uff20](.*?)\Z/.match(str).to_a.collect(&:strip)
        }.collect {|res_string, place, votes, res_name, res_series|
          char_index = character_arr.index {|j_name, _| j_name == res_name}
          series_index = series_arr.index {|j_series, _| j_series == res_series}
          unless char_index && series_index
            @alert = "Couldn't find #{char_index ? 'series' : 'character'} transliteration for '#{res_string}'"
            return
          end
          char_entry = character_arr[char_index]
          series_entry = series_arr[series_index]
          total_votes += votes.to_i
          [place.to_i, votes.to_i, nil, char_entry.last, series_entry.last]
        }.collect {|place, votes, _, e_name, e_series|
          vote_share = votes.to_f / total_votes.to_f
          "#{place.ordinalize} #{votes} (#{format_percent(vote_share)}) #{e_name} @ #{e_series}"
        }.join('<br />').html_safe
      end

    else
      render
    end
  end
end
