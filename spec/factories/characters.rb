# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :character do
    first_name "First"
    last_name "Last"
    given_name "Given"

    trait :empty do
      first_name ""
      last_name ""
      given_name ""
    end

    trait :first do
      first_name "First"
    end

    trait :given do
      given_name "Given"
    end

    factory :empty_character, traits: [:empty]
    factory :character_with_first_only, traits: [:empty, :first]
    factory :character_with_given_only, traits: [:empty, :given]
  end
end
