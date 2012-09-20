class DurationKind < ActiveRecord::Base
  belongs_to :production_category
  has_many :work_entry_durations, :foreign_key => :kind_code, :primary_key => :code
end
