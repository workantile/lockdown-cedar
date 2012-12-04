require 'spec_helper'

describe Door do
  before(:each) do
    @door = FactoryGirl.create(:door)
    @door.save
  end

  it { should respond_to :name }
  it { should respond_to :address }
  it { should respond_to :shared_secret }

  it { should validate_presence_of :name }
  it { should validate_presence_of :address }

  it { should validate_uniqueness_of :name }
  it { should validate_uniqueness_of :address }
  
end
