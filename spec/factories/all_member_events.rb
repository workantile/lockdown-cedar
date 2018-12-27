FactoryBot.define do
  factory :all_member_event do
    # scheduled DateTime.new(2012, 2, 1, 19, 0, 0)
    scheduled { '1/10/2012 07:00 pm' }
    name { 'Social Lunch' }
  end
end
