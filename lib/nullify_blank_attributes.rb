# Mixin with ActiveRecord::Base
module NullifyBlankAttributes
  def write_attribute(attr_name, value)
    super(attr_name, value.presence)
  end
end