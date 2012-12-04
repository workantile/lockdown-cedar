# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :access_log do
    access_date Date.today
    association :member, factory: :full_member

    trait :success do
    	access_granted true
    end

    trait :failure do
    	access_granted true
    	msg 'take a hike!'
    end

    factory :log_success, :traits => [:success]
    factory :log_failure, :traits => [:failure]

  end
end
