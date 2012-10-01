class WorkEntryDuration < ActiveRecord::Base
  belongs_to :work_entry
  belongs_to :duration_kind, :foreign_key => :kind_code, :primary_key => :code
  belongs_to :production_category

  attr_accessible :duration_string, :created_by, :modified_by, :kind_code

  before_save :sanitize_duration

  def duration_string
    if duration
      vals = duration.split(":")
      "#{vals[0]}h #{vals[1]}m"
    else
      "00:00:00"
    end
  end

  def duration_string=(s)
    vals = s.gsub(/[hm]/, "").split(" ")
    self.duration = "#{vals[0]}:#{vals[1]}:00"
  end

  private
  def sanitize_duration
    self.date_created = DateTime.now unless self.date_created
  end
  
end
