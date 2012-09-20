class WorkChart < ActiveRecord::Base
  set_table_name :work_chart

  has_many :work_chart_kind_sets
  belongs_to :work_chart_status, :foreign_key => :status, :primary_key => :status
  has_many :work_entries
end
