require 'spec_helper'

describe Member do
  before(:each) do
    @member = FactoryGirl.create(:full_member)
    @member.save
  end

  it { should respond_to :full_name }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:member_type) }

  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:rfid)}

  it { should ensure_inclusion_of(:member_type).in_array(['full',
  																											 'full - no work',
  																											 'affiliate',
  																											 'student',
  																											 'key-only']) }

end
