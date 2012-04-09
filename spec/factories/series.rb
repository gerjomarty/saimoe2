# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :series do
    name "Series Name"
    color_code nil

    trait :with_color_code do
      color_code "123456"
    end

    trait :with_incorrect_color_code do
      color_code "XDJRHF"
    end

    factory :series_with_color_code, traits: [:with_color_code]
    factory :series_with_incorrect_color_code, traits: [:with_incorrect_color_code]
  end
end
