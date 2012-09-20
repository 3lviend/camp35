class ProductionCategory < ActiveRecord::Base
  has_many :duration_kinds
  has_many :work_entry_durations
end
