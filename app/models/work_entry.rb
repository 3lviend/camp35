class WorkEntry < ActiveRecord::Base
  belongs_to :work_chart
  has_many :work_entry_durations
  has_many :work_entry_fees
  belongs_to :work_entry_status, :foreign_key => :status_code, :primary_key => :code
end
