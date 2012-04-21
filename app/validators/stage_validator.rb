class StageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    unless MatchInfo::STAGES.include? value
      record.errors[attribute] << "is not a valid stage"
    end
  end
end

class GroupStageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    unless MatchInfo::GROUP_STAGES.include? value
      record.errors[attribute] << "is not a valid group stage"
    end
  end
end

class FinalStageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    unless MatchInfo::FINAL_STAGES.include? value
      record.errors[attribute] << "is not a valid final stage"
    end
  end
end