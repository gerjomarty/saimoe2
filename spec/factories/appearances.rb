# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :appearance do
    character_display_name nil

    character_role
    tournament
  end
end
