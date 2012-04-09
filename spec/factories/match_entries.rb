# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :match_entry do
    position 1

    match
    association :previous_match, factory: :match
    appearance
  end
end
