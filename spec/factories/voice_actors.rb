# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :voice_actor do
    first_name "First"
    last_name "Last"

    trait :empty do
      first_name nil
      last_name nil
    end

    trait :last_only do
      last_name "Last"
    end

    factory :empty_voice_actor, traits: [:empty]
    factory :voice_actor_with_last_only, traits: [:empty, :last_only]
  end
end
