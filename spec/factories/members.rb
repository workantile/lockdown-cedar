# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
  	first_name				"joe"
  	last_name					"member"
  	sequence(:email)	{ |n| "joe#{n}@foobar.net" }
  	sequence(:rfid) 	{ |n| "#{n}" }
  	anniversary_date	Date.new(2012, 11, 1)

  	trait :full do
  		member_type			"current"
      billing_plan    "full"
  	end

  	trait :full_no_work do
  		member_type			"current"
      billing_plan    "full - no work"
  	end

  	trait :affiliate do
  		member_type			"current"
      billing_plan    "affiliate"
  	end

  	trait :student do
  		member_type			"current"
      billing_plan    "student"
  	end

  	trait :courtesy_key do
  		member_type		"courtesy key"
      billing_plan  "none"
  	end

    trait :former do
      member_type   "former"
      billing_plan  "none"
    end

  	factory :full_member, :traits => [:full]
  	factory :full_no_work_member, :traits => [:full_no_work]
  	factory :affiliate_member, :traits => [:affiliate]
  	factory :student_member, :traits => [:student]
    factory :former_member, :traits => [:former]
  	factory :courtesy_key, :traits => [:courtesy_key]
  end
end
