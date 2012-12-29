# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :snapshot do
    category "MyString"
    item "MyString"
    count 1
    snapshot_date "2012-12-29"
  end
end
