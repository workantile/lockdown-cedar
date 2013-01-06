# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :access_log do
    association :member, factory: :full_member

    trait :success do
        member_name     'Joe Member'
        member_type     'full'
        door_name       'alley'
    	access_granted true
    end

    trait :failure do
    	access_granted false
    	msg 'take a hike!'
    end

    factory :log_success, :traits => [:success]
    factory :log_failure, :traits => [:failure]

  end
end
