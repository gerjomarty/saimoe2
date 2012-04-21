class StageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    value = [value] unless Array === value
    unless value.all? {|v| MatchInfo::STAGES.include? v }
      record.errors[attribute] << "is not a valid stage"
    end
  end
end

class GroupStageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    value = [value] unless Array === value
    unless value.all? {|v| MatchInfo::GROUP_STAGES.include? v }
      record.errors[attribute] << "is not a valid group stage"
    end
  end
end

class FinalStageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    value = [value] unless Array === value
    unless value.all? {|v| MatchInfo::FINAL_STAGES.include? v }
      record.errors[attribute] << "is not a valid final stage"
    end
  end
end