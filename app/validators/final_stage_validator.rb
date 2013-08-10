class FinalStageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    value = [value] unless Array === value
    value.compact!
    unless value.all? {|v| MatchInfo::FINAL_STAGES.include? v }
      record.errors[attribute] << "#{value} contains an invalid final stage"
    end
  end
end
