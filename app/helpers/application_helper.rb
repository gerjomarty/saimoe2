module ApplicationHelper
  def format_percent number
    num = number * 100
    if fewer_decimal_places_than num, 1
      "%.0f%%" % num
    elsif fewer_decimal_places_than num, 2
      "%.1f%%" % num
    else
      "%.2f%%" % num
    end
  end

  def pretty_match match
    if match.stage == :final
      "Grand Final"
    elsif MatchInfo::FINAL_STAGES.include? match.stage
      "#{pretty_stage match.stage} #{match.match_number}"
    elsif match.stage == :group_final
      "#{pretty_group match.group} Final"
    else
      "#{pretty_stage match.stage} Match #{match.group.upcase}#{match.match_number}"
    end
  end

  def pretty_stage stage
    return '' unless stage
    stage.to_s.gsub(/_/, ' ').titleize
  end

  def pretty_group group
    return '' unless group
    "group #{group}".titleize
  end

  private

  def fewer_decimal_places_than number, places
    decimals = 0
    while number != number.to_i
      decimals += 1
      number *= 10
      return false if decimals >= places
    end
    decimals < places
  end
end
