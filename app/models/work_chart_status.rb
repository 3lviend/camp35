class WorkChartStatus < ActiveRecord::Base
  has_many :work_charts, :foreign_key => :status, :primary_key => :status
end
