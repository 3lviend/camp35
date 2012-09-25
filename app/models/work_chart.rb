class WorkChart < ActiveRecord::Base
  set_table_name :work_chart

  attr_accessor :full_label
  attr_accessor :position

  has_many :work_chart_kind_sets
  belongs_to :work_chart_status, :foreign_key => :status, :primary_key => :status
  has_many :work_entries

  def self.all_with_labels
    sql = <<-eos
      SELECT "work_chart".*, "work_chart_tree_view"."branch", "work_chart_tree_view"."pos" 
      FROM work_chart 
      INNER JOIN work_chart_tree_view
        ON "work_chart"."id" = "work_chart_tree_view"."id" 
      WHERE "work_chart"."parent_id" IS NOT NULL
      ORDER BY "work_chart_tree_view"."pos"
    eos
    #throw WorkChart.find_by_sql(sql).to_a.first
    @work_chart_hash = WorkChart.find_by_sql(sql).to_a.inject({}) { |a, c| a[c.id] = c; a }
    @work_charts = @work_chart_hash.values.map do |chart|
      ids = chart.branch.split('~').map(&:to_i)
      chart.full_label = ids.map { |id| if id == ids.last; @work_chart_hash[id].display_label; else; "----"; end }.join
      chart
    end
    @work_charts
  end
end
