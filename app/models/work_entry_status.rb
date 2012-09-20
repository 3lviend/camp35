class WorkEntryStatus < ActiveRecord::Base
  has_many :work_entries, :foreign_key => :status_code, :primary_key => :code
end
