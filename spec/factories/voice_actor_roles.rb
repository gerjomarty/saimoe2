# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :voice_actor_role do
    has_no_voice_actor false

    appearance
    voice_actor
  end
end
