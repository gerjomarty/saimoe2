class StageValidator < ActiveModel::EachValidator
  def validate_each record, attribute, value
    value = [value] unless Array === value
    value.compact!
    unless value.all? {|v| MatchInfo::STAGES.include? v }
      record.errors[attribute] << "#{value} contains an invalid stage"
    end
  end
end
