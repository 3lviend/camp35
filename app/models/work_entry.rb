class WorkEntry < ActiveRecord::Base
  belongs_to :work_chart
  has_many :work_entry_durations
  has_many :work_entry_fees
  belongs_to :work_entry_status, :foreign_key => :status_code, :primary_key => :code

  accepts_nested_attributes_for :work_entry_fees, :work_entry_durations
  attr_accessible :work_chart_id, :date_performed, :work_entry_fees_attributes, :description, :work_entry_durations_attributes, :created_by, :modified_by

  before_save :sanitize_entry

  # TODO: optimize because this is painfully 
  def work_chart_label
    if @work_chart_entry
      return @work_chart_entry
    else
      sql = <<-eos
        SELECT "work_chart"."display_label" 
        FROM work_chart 
        INNER JOIN 
          (SELECT CAST(regexp_split_to_table(branch, '~') as integer) AS b 
           FROM work_chart_tree_view 
           WHERE id = #{self.work_chart_id}) as bs 
        ON "work_chart"."id" = "bs"."b" 
        WHERE "work_chart"."parent_id" 
        IS NOT NULL order by "bs"."b"
      eos
      @work_chart_entry = WorkEntry.connection.execute(sql).to_a.map {|c| c["display_label"]}.join(" -> ")
      @work_chart_entry
    end
  end

  def total_duration
    self.work_entry_durations.map(&:duration).map { |d| Time.parse(d).to_datetime}.inject(Time.parse("00:00:00").to_datetime) { |v, a| a+= v.hour.hours; a+= v.min.minutes; a }
  end

  def sanitize_entry
    self.date_created = DateTime.now unless self.date_created
  end

end
