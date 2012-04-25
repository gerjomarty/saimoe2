class StageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    value = [value] unless Array === value
    unless value.all? {|v| MatchInfo::STAGES.include? v }
      record.errors[attribute] << "is not a valid stage"
    end
  end
end
