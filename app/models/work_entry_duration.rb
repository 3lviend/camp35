class WorkEntryDuration < ActiveRecord::Base
  belongs_to :work_entry
  belongs_to :duration_kind, :foreign_key => :kind_code, :primary_key => :code
  belongs_to :production_category

  attr_accessible :duration_hours, :duration_minutes, :created_by, :modified_by, :kind_code

  after_initialize :sanitize_duration

  def duration_hours
    duration.nil? ? "00" : duration.split(":").first 
  end

  def duration_hours=(h)
    self.duration = "#{'%02d' % h}:#{duration_minutes}:00"
  end

  def duration_minutes=(m)
    self.duration = "#{duration_hours}:#{'%02d' % m}:00"
  end
 
  def duration_minutes
    duration.nil? ? "00" : duration.split(":")[1]
  end

  private
  def sanitize_duration
    self.date_created = DateTime.now unless self.date_created
    self.duration = "00:00:00" unless self.duration
  end
  
end
