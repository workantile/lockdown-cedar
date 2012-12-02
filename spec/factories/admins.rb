# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin do
  	email 	"foo@bar.com"
  	password "test_password"

  	trait :other_admin do
  		email	"otherfoo@bar.com"
  	end

  	factory :other_admin, :traits => [:other_admin]
  end
end
