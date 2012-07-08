require 'csv'

class Admin::AdminController < ApplicationController
  include ApplicationHelper
  USERNAME = ENV['APP_USERNAME']
  PASSWORD = ENV['APP_PASSWORD']

  http_basic_authenticate_with name: USERNAME, password: PASSWORD
  force_ssl

  def utilities
    unless (info = params && params[:info])
      render
      return
    end

    character_arr = series_arr = nil
    character_string, series_string = info[:character_csv].read, info[:series_csv].read

    character_string = character_string.force_encoding('SHIFT_JIS').encode('UTF-8', undef: :replace)
    series_string = series_string.force_encoding('SHIFT_JIS').encode('UTF-8', undef: :replace)

    begin
      c_done = false
      character_arr = CSV.parse(character_string)
      c_done = true
      series_arr = CSV.parse(series_string)
    rescue CSV::MalformedCSVError => e
      flash[:alert] = "Malformed CSV input in #{c_done ? 'series' : 'characters'} file: #{e}"
      return
    end

    character_arr.collect! {|i| i.compact.collect {|ii| ii.try(:strip).try(:chomp).try(:strip)}.compact }
    series_arr.collect! {|i| i.compact.collect {|ii| ii.try(:strip).try(:chomp).try(:strip)}.compact }
    character_arr.collect! {|i| i.empty? ? nil : i}
    series_arr.collect! {|i| i.empty? ? nil : i}
    character_arr.compact!
    series_arr.compact!

    unless character_arr.all? {|i| i.size == 2} || series_arr.all? {|i| i.size == 2}
      flash[:alert] = "Some lines not in correct format: #{(character_arr + series_arr).select {|i| i.size != 2}.inspect}"
      return
    end

    character_arr.sort_by! do |_, e_name|
      split_name = e_name.try(:split, / /)
      if split_name.nil? || split_name.size == 1
        [e_name || '']
      else
        [split_name.last, e_name || '']
      end
    end
    series_arr.sort_by! {|_, e_series| [e_series]}

    if info[:transform] == 'name_list'

      name_string = info[:name_csv].read
      name_string = name_string.force_encoding('SHIFT_JIS').encode('UTF-8', undef: :replace)
      name_arr = name_string.lines.to_a.collect {|l| l.try(:strip).try(:chomp).try(:strip)}.compact
      name_arr.collect! {|l| l.empty? ? nil : l}
      name_arr.compact!

      @result = name_arr.collect {|str|
        #/\A<<(.*?)[@\uff20](.*?)>>\Z/.match(str).to_a.collect(&:strip)
        /\A[^\p{Space}]+\p{Space}(.*?)[@\uff20](.*?)\Z/.match(str).to_a.collect(&:strip)
      }.collect {|id_string, id_name, id_series|
        char_index = character_arr.index {|j_name, _| j_name == id_name}
        series_index = series_arr.index {|j_series, _| j_series == id_series}
        j_name, e_name, j_series, e_series = nil
        j_name, e_name = character_arr[char_index] if char_index
        j_series, e_series = series_arr[series_index] if series_index
        [id_string, j_name, e_name, j_series, e_series]
      }.sort_by {|_, _, e_name, _, e_series|
        split_name = e_name.try(:split, / /)
        if split_name.nil? || split_name.size == 1
          [(e_name.nil? || e_series.nil?) ? 0 : 1, e_series || '', e_name || '']
        else
          [(e_name.nil? || e_series.nil?) ? 0 : 1, e_series || '', split_name.last, e_name || '']
        end
      }.collect {|id_string, j_name, e_name, j_series, e_series|
        "#{e_name || '???'} @ #{e_series || '???'}: #{j_name && j_series ? %Q|<<#{j_name}\uff20#{j_series}>>| : id_string}"
      }.join("\r\n")

      send_data @result, filename: "name_list_#{Time.zone.now}.txt"

    elsif info[:transform] == 'result_list'

      result_string = info[:result_csv].read
      result_string = result_string.force_encoding('Shift_JIS').encode('UTF-8')
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
          str << " <<#{j_name}\uff20#{j_series}>>"
        end
      }.join("\r\n")

      send_data @result, filename: "result_list_#{Time.zone.now}.txt"
    end
  end
end
