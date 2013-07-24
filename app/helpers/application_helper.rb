module ApplicationHelper
  # Takes a float between 0 and 1, and outputs a percentage with up to two decimal places
  def format_percent number
    num = number * 100
    format_float(num) << "%"
  end

  def format_float number
    number = number.to_f
    if fewer_decimal_places_than number, 1
      "%.0f" % number
    elsif fewer_decimal_places_than number, 2
      "%.1f" % number
    else
      "%.2f" % number
    end
  end

  def bright_color hex_string
    return nil unless hex_string
    rgb = hex_string.sub(/\A#/, '').scan(/../).map {|color| color.to_i(16)}
    (0.299*rgb[0] + 0.587*rgb[1] + 0.114*rgb[2]) > 100
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
