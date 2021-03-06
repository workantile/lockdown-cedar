class AllMemberEvent < ActiveRecord::Base
  attr_accessible :name, :scheduled

  validates_presence_of :name, :scheduled

  default_scope { order("scheduled DESC") }

  def scheduled=(a_date)
    if a_date.instance_of?(String) && !a_date.empty?
      local_time = Date._strptime(a_date, "%m/%d/%Y %I:%M %P")
      self[:scheduled] = DateTime.civil_from_format(
        'local',
        local_time[:year],
        local_time[:mon],
        local_time[:mday],
        local_time[:hour],
        local_time[:min]
      )
    else
      self[:scheduled] = a_date
    end
  end

  def formatted_display
    if scheduled.hour == 0
      scheduled.strftime("%m/%d/%Y all day")
    else
      scheduled.strftime("%m/%d/%Y %l:%M %P")
    end
  end

  def self.event_happening?
    now = DateTime.current
    AllMemberEvent.where(:scheduled => now.beginning_of_day ..(now + 1.hour)).exists?
  end

end
