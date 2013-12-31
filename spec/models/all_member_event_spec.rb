require 'spec_helper'

describe AllMemberEvent do
  let!(:all_member_event)  { FactoryGirl.create(:all_member_event)}

  it { should respond_to :name }
  it { should respond_to :scheduled }

  it { should validate_presence_of :name }
  it { should validate_presence_of :scheduled }
  
end
