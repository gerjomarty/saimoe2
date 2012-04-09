# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tournament do
    sequence(:year, 2000) {|n| n.to_s}
  end
end
