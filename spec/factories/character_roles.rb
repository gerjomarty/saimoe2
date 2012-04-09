# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :character_role do
    role_type "major"

    character
    series
  end
end
