class GroupStageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    value = [value] unless Array === value
    unless value.all? {|v| MatchInfo::GROUP_STAGES.include? v }
      record.errors[attribute] << "is not a valid group stage"
    end
  end
end
