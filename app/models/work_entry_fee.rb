class WorkEntryFee < ActiveRecord::Base
  belongs_to :work_entry
  attr_accessible :fee, :date_created, :last_modified, :work_entry_id, :modified_by, :created_by

  before_save :sanitize_fee

  private
  def sanitize_fee
    self.date_created = DateTime.now unless self.date_created
  end
end
