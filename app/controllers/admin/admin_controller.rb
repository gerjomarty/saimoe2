require 'csv'

class Admin::AdminController < ApplicationController
  USERNAME = ENV['APP_USERNAME']
  PASSWORD = ENV['APP_PASSWORD']

  http_basic_authenticate_with name: USERNAME, password: PASSWORD
  force_ssl

  def utilities
    if (info = params && params[:info])

      info_arr = CSV.parse(info[:character_series_csv].chomp)

      unless info_arr.all? {|i| i.size == 4}
        @result = "Malformed CSV input - #{info_arr.select {|i| i.size != 4}.inspect}"
        return
      end

      info_arr.collect! {|i| [i[0..1], i[2..3]]}
      info_arr.sort_by! {|char_t, series_t| [series_t.last, char_t.last.split(/ /).last, char_t.last]}

      if info[:transform] == 'name_list'

        if (name_arr = CSV.parse(info[:name_csv].chomp)).empty?
          # The list of Japanese identifiers is empty - just output the whole list
          @result = info_arr.collect {|char_t, series_t|
            "#{char_t.last} @ #{series_t.last}: &lt;&lt;#{char_t.first}@#{series_t.first}&gt;&gt;"
          }.join('<br />').html_safe
        else
          # The list of Japanese identifiers is not empty - convert and sort that list
          name_series = name_arr.collect {|str| /\A<<([\w\s]+)@([\w\s]+)>>\Z/.match(str).to_a}
          @result = name_series.collect {|j_string, j_name, j_series|
            entry = info_arr.select {|char_t, series_t| char_t.first == j_name && series_t.first == j_series}[0]
            "#{entry.first.last} @ #{entry.last.last}: #{j_string}"
          }.join('<br />').html_safe
        end

      elsif info[:transform] == 'result_list'

        result_arr = CSV.parse(info[:result_csv].chomp)

        #TODO
      end

    else
      render
    end
  end
end
