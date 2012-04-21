# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :match_entry do
    position 1

    match
    previous_match
    appearance
  end
end
