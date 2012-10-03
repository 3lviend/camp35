# This class should be refactored.
# Existaing methods are to be treated as proofs of concepts.
# They work but do it very slowly.
class WorkChart < ActiveRecord::Base
  set_table_name :work_chart

  attr_accessor :full_label
  attr_accessor :position

  has_many :work_chart_kind_sets
  has_many :work_chart_kinds
  belongs_to :work_chart_status, :foreign_key => :status, :primary_key => :status
  has_many :work_entries

  # 20 most recent and 20 most popular
  # over the last three months
  def self.frequently_used(user)
    # this code is intentionally not optimal
    # TODO: refactor!
    frequent_sql = <<-eos
      SELECT work_chart_id, count(*) AS chart_count 
      FROM work_entries 
      WHERE 
        date_performed > date('#{3.month.ago.to_formatted_s(:db)}') AND 
        role_id = #{user.system_role_id}
      GROUP BY work_chart_id 
      ORDER BY chart_count DESC 
      LIMIT 20;
    eos
    last_sql = <<-eos
      SELECT work_chart_id, MAX(date_performed) AS last_date 
      FROM work_entries 
      WHERE 
        role_id = #{user.system_role_id}
      GROUP BY work_chart_id 
      ORDER BY last_date DESC 
      LIMIT 20;
    eos
    frequent = WorkChart.find_by_sql(frequent_sql).map(&:work_chart_id)
    last     = WorkChart.find_by_sql(last_sql).map(&:work_chart_id)
    ids = (frequent + last).uniq
    WorkChart.find ids.map(&:to_i)
  end

  def labels
    unless @labels
      sql = <<-eos
        SELECT "work_chart"."display_label" 
        FROM work_chart 
        INNER JOIN 
          (SELECT CAST(regexp_split_to_table(branch, '~') as integer) AS b 
           FROM work_chart_tree_view 
           WHERE id = #{id}) as bs 
        ON "work_chart"."id" = "bs"."b" 
        WHERE 
          "work_chart"."parent_id" IS NOT NULL
        ORDER BY "bs"."b"
      eos
      @labels = WorkChart.connection.execute(sql).to_a.map {|c| c["display_label"]}
    end
    @labels
  end

  def self.all_with_labels
    # naive implementation - should be refactored!
    all = WorkChart.where("parent_id IS NOT NULL")
    root = all.where(parent_id: 1).first
    children_for(root, all)
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
