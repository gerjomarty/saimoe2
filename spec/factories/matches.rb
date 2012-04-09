# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :match do
    tournament

    group :a
    stage :round_1
    match_number 1
    date { Date.today }

    trait :empty do
      group nil
      stage nil
      match_number nil
    end

    trait :group_final do
      group "a"
      stage :group_final
    end

    trait :quarter_final do
      stage :quarter_final
      match_number 1
    end

    trait :final do
      stage :final
    end

    factory :group_final_match, traits: [:empty, :group_final]
    factory :quarter_final_match, traits: [:empty, :quarter_final]
    factory :final_match, traits: [:empty, :final]
  end
end
