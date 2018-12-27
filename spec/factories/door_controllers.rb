# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :door_controller do
    address { "deadbeef01" }
    location { "front door" }
    success_response { "<OK>" }
    error_response { "<ERROR>" }
  end
end
