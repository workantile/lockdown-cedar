# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
  	first_name				"joe"
  	last_name					"member"
  	sequence(:email)	{ |n| "joe#{n}@foobar.net" }
  	sequence(:rfid) 	{ |n| "#{n}" }
  	anniversary_date	Date.today.strftime("%m/%d/%Y")

  	trait :full do
  		member_type			"full"
  	end

  	trait :full_no_work do
  		member_type			"full - no work"
  	end

  	trait :affiliate do
  		member_type			"affiliate"
  	end

  	trait :student do
  		member_type			"student"
  	end

  	trait :non_member do
  		member_type		"non-member"
  	end

  	factory :full_member, :traits => [:full]
  	factory :full_no_work_member, :traits => [:full_no_work]
  	factory :affiliate_member, :traits => [:affiliate]
  	factory :student_member, :traits => [:student]
  	factory :key_only_member, :traits => [:non_member]
  end
end
