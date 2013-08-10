class GroupValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    if Match === record && record.final_match?
      record.errors[attribute] << "must be nil for a final match" unless value.nil?
    else
      record.errors[attribute] << "is not a valid group" unless value && value =~ /\A[\w_]+\Z/
    end
  end
end