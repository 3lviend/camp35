class WorkEntryDuration < ActiveRecord::Base
  belongs_to :work_entry
  belongs_to :duration_kind, :foreign_key => :kind_code, :primary_key => :code
  belongs_to :production_category
end
