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
      info_arr = nil
      begin
        info_arr = CSV.parse(info[:character_series_csv]).collect {|i| i.collect(&:strip).collect(&:chomp)}
      rescue CSV::MalformedCSVError => e
        @alert = "Malformed CSV input: #{e}"
        return
      end

      unless info_arr.all? {|i| i.size == 4}
        @alert = "Some lines not in correct format: #{info_arr.select {|i| i.size != 4}.inspect}"
        return
      end

      info_arr.sort_by! {|_, e_name, _, e_series| [e_series, e_name.split(/ /).last, e_name]}

      if info[:transform] == 'name_list'

        if (name_arr = info[:name_csv].lines.to_a.collect {|l| l.strip.chomp.strip}).empty?

          # The list of Japanese identifiers is empty - just output the whole list

          @result = info_arr.collect {|j_name, e_name, j_series, e_series|
            "#{e_name} @ #{e_series}: &lt;&lt;#{j_name}\uff20#{j_series}&gt;&gt;"
          }.join('<br />').html_safe

        else

          # The list of Japanese identifiers is not empty - convert and sort that list

          @result = name_arr.collect {|str|
            /\A<<(.*?)[@\uff20](.*?)>>\Z/.match(str).to_a.collect(&:strip)
          }.collect {|id_string, id_name, id_series|
            index = info_arr.index {|j_name, _, j_series, _| j_name == id_name && j_series == id_series}
            unless index
              @alert = "Couldn't find transliteration for '#{id_string}''"
              return
            end
            [index, id_name, id_series]
          }.sort_by {|index, _, _|
            [index]
          }.collect {|index, id_name, id_series|
            j_name, e_name, j_series, e_series = info_arr[index]
            "#{e_name} @ #{e_series}: &lt;&lt;#{j_name}\uff20#{j_series}&gt;&gt;"
          }.join('<br />').html_safe

        end

      elsif info[:transform] == 'result_list'

        result_arr = info[:result_csv].lines.to_a.collect {|l| l.strip.chomp.strip}

        total_votes = 0
        result_parts = result_arr.collect {|str|
          /\A(\p{Digit}+)\p{Alpha}+\p{Space}+(\p{Digit}+)\p{Alpha}+\p{Space}+(.*?)[@\uff20](.*?)\Z/.match(str).to_a.collect(&:strip)
        }.collect {|res_string, place, votes, res_name, res_series|
          index = info_arr.index {|j_name, _, j_series, _| j_name == res_name && j_series == res_series}
          unless index
            @alert = "Couldn't find transliteration for '#{res_string}''"
            return
          end
          entry = info_arr[index]
          total_votes += votes.to_i
          [place.to_i, votes.to_i, nil, entry[1], entry[3]]
        }

        @result = result_parts.collect {|res|
          res[2] = res[1].to_f / total_votes.to_f
          "#{res[0].ordinalize} #{res[1]} (#{format_percent(res[2])}) #{res[3]} @ #{res[4]}"
        }.join('<br />').html_safe
      end

    else
      render
    end
  end
end
