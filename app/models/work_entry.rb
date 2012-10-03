class WorkEntry < ActiveRecord::Base
  belongs_to :work_chart
  has_many :work_entry_durations
  has_many :work_entry_fees
  belongs_to :work_entry_status, :foreign_key => :status_code, :primary_key => :code

  accepts_nested_attributes_for :work_entry_fees, :work_entry_durations
  attr_accessible :work_chart_id, :date_performed, :work_entry_fees_attributes, :description, :work_entry_durations_attributes, :created_by, :modified_by

  before_save :sanitize_entry
  validates_presence_of :work_chart

  def work_chart_label_parts
    work_chart.labels
  end

  def total_duration
    self.work_entry_durations.map(&:duration).map { |d| Time.parse(d).to_datetime}.inject(Time.parse("00:00:00").to_datetime) { |v, a| a+= v.hour.hours; a+= v.min.minutes; a }
  end

  def sanitize_entry
    self.date_created = DateTime.now unless self.date_created
  end

end
