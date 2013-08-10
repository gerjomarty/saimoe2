class GroupStageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    value = [value] unless Array === value
    value.compact!
    unless value.all? {|v| MatchInfo::GROUP_STAGES.include? v }
      record.errors[attribute] << "#{value} contains an invalid group stage"
    end
  end
end
