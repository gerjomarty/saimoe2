# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:year, 2000) {|n| n.to_s}

  factory :tournament do
    year { FactoryGirl.generate :year }
    group_stages [:round_1, :round_2]
    final_stages [:quarter_final, :semi_final, :final]
  end
end
