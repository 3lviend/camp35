class WorkChart < ActiveRecord::Base
  set_table_name :work_chart

  attr_accessor :full_label
  attr_accessor :position

  has_many :work_chart_kind_sets
  has_many :work_chart_kinds
  belongs_to :work_chart_status, :foreign_key => :status, :primary_key => :status
  has_many :work_entries

  def self.all_with_labels
    # naive implementation
    all = WorkChart.where("parent_id IS NOT NULL")
    result = {}
    root = all.where(parent_id: 1).first
    result[root.display_label] = children_for(root, all) # {}
    result
  end

  # WorkChart -> [WorkChart] -> {}
  def self.children_for(branch, all)
    result = {}
    children = all.where(parent_id: branch.id)
    if children.count > 0
      children.each { |c| result[c.display_label] = children_for(c, all) }
      return Hash[result.sort]
    else
      branch.id
    end
  end

  # returns tree like structure e.g "Something": { "Other": 1, "Other2": 2}, "Something2: ... 
  # as ruby hash
  def self.all_with_labels2
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
    @result = {}
    @root = @work_chart_hash.select { |c| c.branch.split("~").count == 2 }.first
    @result[@root.name] = {}
    #@work_chart_hash.values.each do |chart|
    #  ids = chart.branch.split('~').map(&:to_i)
    #  chart.full_label = ids.map { |id| if id == ids.last; @work_chart_hash[id].display_label; else; "----"; end }.join
    #  chart
    #end
    @work_chart_hash
  end
end
