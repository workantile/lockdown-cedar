require 'rails_helper'

describe DoorController do
  before(:each) do
    @door_controller = FactoryBot.create(:door_controller)
    @door_controller.save
  end

  it { is_expected.to respond_to :address }
  it { is_expected.to respond_to :location }
  it { is_expected.to respond_to :success_response }
  it { is_expected.to respond_to :error_response}

  it { is_expected.to validate_presence_of :address }
  it { is_expected.to validate_presence_of :location }

  it { is_expected.to validate_uniqueness_of :address }
  it { is_expected.to validate_uniqueness_of :location }

end
