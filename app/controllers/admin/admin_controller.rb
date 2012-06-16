require 'csv'

class Admin::AdminController < ApplicationController
  include ApplicationHelper
  USERNAME = ENV['APP_USERNAME']
  PASSWORD = ENV['APP_PASSWORD']

  http_basic_authenticate_with name: USERNAME, password: PASSWORD
  force_ssl

  def utilities
    if (info = params && params[:info])

      character_arr = nil
      series_arr = nil
      begin
        character_arr = CSV.parse(info[:character_csv].read).collect {|i| i.collect {|ii| ii.strip.chomp.strip}}
        series_arr = CSV.parse(info[:series_csv].read).collect {|i| i.collect {|ii| ii.strip.chomp.strip}}
      rescue CSV::MalformedCSVError => e
        flash[:alert] = "Malformed CSV input: #{e}"
        return
      end

      unless character_arr.all? {|i| i.size == 2} || series_arr.all? {|i| i.size == 2}
        flash[:alert] = "Some lines not in correct format: #{(character_arr + series_arr).select {|i| i.size != 2}.inspect}"
        return
      end

      character_arr.sort_by! {|_, e_name| [(split_name = e_name.split(/ /)).size == 1 ? nil : split_name.last, e_name]}
      series_arr.sort_by! {|_, e_series| [e_series]}

      if info[:transform] == 'name_list'

        name_arr = info[:name_csv].read.lines.to_a.collect {|l| l.strip.chomp.strip}

        @result = name_arr.collect {|str|
          /\A<<(.*?)[@\uff20](.*?)>>\Z/.match(str).to_a.collect(&:strip)
        }.collect {|id_string, id_name, id_series|
          char_index = character_arr.index {|j_name, _| j_name == id_name}
          series_index = series_arr.index {|j_series, _| j_series == id_series}
          [char_index, series_index, id_name, id_series]
        }.sort_by {|char_index, series_index, _, _|
          [series_index, char_index]
        }.collect {|char_index, series_index, id_name, id_series|
          j_name, e_name, j_series, e_series = nil
          j_name, e_name = character_arr[char_index] if char_index
          j_series, e_series = series_arr[series_index] if series_index
          "#{e_name || '???'} @ #{e_series || '???'}: &lt;&lt;#{j_name || id_name}\uff20#{j_series || id_series}&gt;&gt;"
        }.join('<br />').html_safe

        send_data @result, filename: "name_list_#{Time.zone.now}.txt"

      elsif info[:transform] == 'result_list'

        result_arr = info[:result_csv].read.lines.to_a.collect {|l| l.strip.chomp.strip}

        total_votes = 0
        @result = result_arr.collect {|str|
          /\A(\p{Digit}+)\p{Alpha}+\p{Space}+(\p{Digit}+)\p{Alpha}+\p{Space}+(.*?)[@\uff20](.*?)\Z/.match(str).to_a.collect(&:strip)
        }.collect {|res_string, place, votes, res_name, res_series|
          char_index = character_arr.index {|j_name, _| j_name == res_name}
          series_index = series_arr.index {|j_series, _| j_series == res_series}
          #unless char_index && series_index
          #  @alert = "Couldn't find #{char_index ? 'series' : 'character'} transliteration for '#{res_string}'"
          #  return
          #end
          total_votes += votes.to_i
          [place.to_i, votes.to_i, nil, char_index, series_index, res_name, res_series]
        }.sort_by {|place, votes, _, char_index, series_index, _, _|
          [place, -votes, series_index, char_index]
        }.collect {|place, votes, _, char_index, series_index, res_name, res_series|
          e_name, e_series = nil
          e_name = character_arr[char_index].last if char_index
          e_series = series_arr[series_index].last if series_index
          vote_share = votes.to_f / total_votes.to_f
          str = "#{place.ordinalize} #{votes} (#{format_percent(vote_share)}) #{e_name || '???'} @ #{e_series || '???'}"
          if char_index && series_index
            str
          else
            str << " &lt;&lt;#{res_name}\uff20#{res_series}&gt;&gt;"
          end
        }.join('<br />').html_safe

        send_data @result, filename: "result_list_#{Time.zone.now}.txt"
      end
    else
      render
    end
  end
end
