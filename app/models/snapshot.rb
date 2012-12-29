class Snapshot < ActiveRecord::Base
  attr_accessible :category, :count, :item, :snapshot_date

  validates_presence_of :category, :count, :item, :snapshot_date

  def self.take_snapshot
  	Member::MEMBER_TYPES.collect do |member_type|
  		Snapshot.create(:category => "member type",
  										:item => member_type,
  										:count => Member.where(:member_type => member_type).count,
  										:snapshot_date => Date.today)
  	end

  	Member::BILLING_PLANS.collect do |billing_plan|
  		Snapshot.create(:category => "billing plan",
  										:item => billing_plan,
  										:count => Member.where(:billing_plan => billing_plan).count,
  										:snapshot_date => Date.today)
  	end
  end

end
