require 'csv'

class Admin::AdminController < ApplicationController
  include ApplicationHelper
  USERNAME = ENV['APP_USERNAME']
  PASSWORD = ENV['APP_PASSWORD']

  http_basic_authenticate_with name: USERNAME, password: PASSWORD
  force_ssl

  def utilities
    if (info = params && params[:info])

      character_arr = series_arr = nil
      character_string, series_string = info[:character_csv].read, info[:series_csv].read

      unless character_string.valid_encoding?
        character_string = character_string.force_encoding('Shift_JIS').encode('UTF-8')
      end
      unless series_string.valid_encoding?
        series_string = series_string.force_encoding('Shift_JIS').encode('UTF-8')
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

      character_arr.collect! {|i| i.collect {|ii| ii.strip.chomp.strip}}
      series_arr.collect! {|i| i.collect {|ii| ii.strip.chomp.strip}}

      unless character_arr.all? {|i| i.size == 2} || series_arr.all? {|i| i.size == 2}
        flash[:alert] = "Some lines not in correct format: #{(character_arr + series_arr).select {|i| i.size != 2}.inspect}"
        return
      end

      character_arr.sort_by! {|_, e_name| [(split_name = e_name.split(/ /)).size == 1 ? nil : split_name.last, e_name]}
      series_arr.sort_by! {|_, e_series| [e_series]}

      if info[:transform] == 'name_list'

        name_string = info[:name_csv].read
        unless name_string.valid_encoding?
          name_string = name_string.force_encoding('Shift_JIS').encode('UTF-8')
        end
        name_arr = name_string.lines.to_a.collect {|l| l.strip.chomp.strip}

        @result = name_arr.collect {|str|
          /\A<<(.*?)[@\uff20](.*?)>>\Z/.match(str).to_a.collect(&:strip)
        }.collect {|id_string, id_name, id_series|
          char_index = character_arr.index {|j_name, _| j_name == id_name}
          series_index = series_arr.index {|j_series, _| j_series == id_series}
          j_name, e_name, j_series, e_series = nil
          j_name, e_name = character_arr[char_index] if char_index
          j_series, e_series = series_arr[series_index] if series_index
          [j_name, e_name, j_series, e_series]
        }.sort_by {|_, e_name, _, e_series|
          [e_series, (split_name = e_name.split(/ /)).size == 1 ? nil : split_name.last, e_name]
        }.collect {|j_name, e_name, j_series, e_series|
          "#{e_name || '???'} @ #{e_series || '???'}: &lt;&lt;#{j_name || id_name}\uff20#{j_series || id_series}&gt;&gt;"
        }.join('<br />').html_safe

        send_data @result, filename: "name_list_#{Time.zone.now}.txt"

      elsif info[:transform] == 'result_list'

        result_string = info[:result_csv].read
        unless result_string.valid_encoding?
          result_string = result_string.force_encoding('Shift_JIS').encode('UTF-8')
        end
        result_arr = result_string.lines.to_a.collect {|l| l.strip.chomp.strip}

        total_votes = 0
        @result = result_arr.collect {|str|
          /\A(\p{Digit}+)\p{Alpha}+\p{Space}+(\p{Digit}+)\p{Alpha}+\p{Space}+(.*?)[@\uff20](.*?)\Z/.match(str).to_a.collect(&:strip)
        }.collect {|res_string, place, votes, res_name, res_series|
          char_index = character_arr.index {|j_name, _| j_name == res_name}
          series_index = series_arr.index {|j_series, _| j_series == res_series}
          j_name, e_name, j_series, e_series = nil
          j_name, e_name = character_arr[char_index] if char_index
          j_series, e_series = series_arr[series_index] if series_index
          total_votes += votes.to_i
          [place.to_i, votes.to_i, j_name, e_name, j_series, e_series]
        }.sort_by {|place, votes, _, e_name, _, e_series|
          [place, -votes, e_series, (split_name = e_name.split(/ /)).size == 1 ? nil : split_name.last, e_name]
        }.collect {|place, votes, j_name, e_name, j_series, e_series|
          vote_share = votes.to_f / total_votes.to_f
          str = "#{place.ordinalize} #{votes} (#{format_percent(vote_share)}) #{e_name || '???'} @ #{e_series || '???'}"
          if e_name && e_series
            str
          else
            str << " &lt;&lt;#{j_name}\uff20#{j_series}&gt;&gt;"
          end
        }.join('<br />').html_safe

        send_data @result, filename: "result_list_#{Time.zone.now}.txt"
      end
    else
      render
    end
  end
end
