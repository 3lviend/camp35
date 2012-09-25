class WorkEntryDuration < ActiveRecord::Base
  belongs_to :work_entry
  belongs_to :duration_kind, :foreign_key => :kind_code, :primary_key => :code
  belongs_to :production_category

  attr_accessible :duration_hours, :duration_minutes, :created_by, :modified_by

  before_save :sanitize_duration

  def duration_hours
    duration.split(":").first.to_i rescue 0
  end

  def duration_minutes
    duration.split(":")[1].to_i rescue 0
  end

  def duration_hours=(hours)
    self.duration = "#{'%02d' % hours}:#{duration_minutes}"
  end

  def duration_minutes=(minutes)
    self.duration = "#{duration_hours}:#{'%02d' % minutes}"
  end

  private
  def sanitize_duration
    self.date_created = DateTime.now unless self.date_created
  end
  
end
