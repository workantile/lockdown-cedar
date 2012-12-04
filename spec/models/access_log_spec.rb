require 'spec_helper'

describe AccessLog do
	before (:each) do
		@access_log = FactoryGirl.create(:log_success)
	end

	it { should respond_to :access_date }
	it { should respond_to :access_granted }
	it { should respond_to :msg }
	it { should respond_to :member_name }
	it { should respond_to :member_type }
	it { should respond_to :door_name }

	it { should belong_to :member }
	it { should belong_to :door }
end
