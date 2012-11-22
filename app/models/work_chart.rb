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
  has_many :work_chart_kinds_defaults

  #define_index do
  #  indexes display_label
  #end

  def self.search_for(phrase)
    search = ChartsSearchClient.new
    search.find phrase
  end

  def duration_kinds
    if @duration_kinds
      @duration_kinds
    else
      query = <<-sql
        SELECT DISTINCT(duration_kinds.code), duration_kinds.*
        FROM duration_kinds INNER JOIN work_chart_kinds ON work_chart_kinds.kind_code = duration_kinds.code
        INNER JOIN
          (SELECT CAST(regexp_split_to_table(branch, '~') as integer) AS b
           FROM work_chart_tree_view
           WHERE id = ?) as bs
        ON work_chart_kinds.work_chart_id = bs.b
      sql
      defaults = self.default_kinds
      @duration_kinds = DurationKind.find_by_sql([query, self.id]).sort {|k| defaults.include?(k.code) ? -1 : 1 }
    end
  end

  def default_kinds
    kinds = WorkChart.connection.execute <<-sql
      SELECT *
      FROM work_chart_kinds_defaults
      INNER JOIN
        (SELECT CAST(regexp_split_to_table(branch, '~') AS integer) AS b
         FROM work_chart_tree_view
         WHERE id = #{self.id}) bs ON bs.b = work_chart_kinds_defaults.work_chart_id
      AND bs.b <> 2;
    sql
    kinds.to_a.map { |k| k["kind_code"] }
  end

  def self.frequent_for(user, limit)
    frequent_sql = <<-eos
        SELECT work_chart_id, count(*) AS chart_count 
        FROM work_entries 
        WHERE 
          role_id = #{user.system_role_id}
        GROUP BY work_chart_id 
        ORDER BY chart_count DESC 
        LIMIT #{limit};
    eos
    charts_with_labels_sql = WorkChart.WITH_LABELS_SQL

    ids = WorkChart.find_by_sql(frequent_sql).map(&:work_chart_id)
    charts_by_id = WorkChart.find_by_sql([charts_with_labels_sql, ids, ids]).to_a.index_by(&:id)
    ids.map {|id| charts_by_id[id.to_i] }
  end

  def self.recent_for(user, limit)
    recent_sql = <<-eos
        SELECT work_chart_id, MAX(date_performed) AS last_date 
        FROM work_entries 
        WHERE 
          role_id = #{user.system_role_id}
        GROUP BY work_chart_id 
        ORDER BY last_date DESC 
        LIMIT #{limit};
    eos
    charts_with_labels_sql = WorkChart.WITH_LABELS_SQL

    ids = WorkChart.find_by_sql(recent_sql).map(&:work_chart_id)
    charts_by_id = WorkChart.find_by_sql([charts_with_labels_sql, ids, ids]).index_by(&:id)
    ids.map {|id| charts_by_id[id.to_i] }
  end

  def self.leafs_with_labels
    ids = WorkChart.find_by_sql <<-sql
      SELECT id
      FROM work_chart
      WHERE id NOT IN
          (SELECT DISTINCT parent_id
          FROM work_chart
          WHERE parent_id IS NOT NULL)
        AND status = 'active'; 
    sql
    ids = ids.map(&:id)
    labels_sql = <<-sql
      WITH RECURSIVE tree AS
        (SELECT display_label,
                id,
                parent_id,
                status,
                NULL::varchar AS parent_name,
                display_label::text AS path
        FROM work_chart
        WHERE parent_id IS NULL
        UNION SELECT f1.display_label,
                      f1.id,
                      f1.parent_id,
                      f1.status,
                      tree.display_label AS parent_name,
                      tree.path || '-' || f1.display_label::text AS path
        FROM tree
        JOIN work_chart f1 ON f1.parent_id = tree.id)
      SELECT id,
            parent_id,
            status,
            path
      FROM tree
      WHERE id in (?)
    sql
    WorkChart.find_by_sql([labels_sql, ids]).map {|c| c["labels"] = c["path"].split("-")[2..100]; c}
  end

  def self.WITH_LABELS_SQL
    <<-sql
      SELECT array(SELECT "work_chart"."display_label"
      FROM work_chart
      INNER JOIN
        (SELECT CAST(regexp_split_to_table(branch, '~') as integer) AS b
         FROM work_chart_tree_view
         WHERE id IN (?)) as bs
      ON "work_chart"."id" = "bs"."b"
      WHERE
        "work_chart"."parent_id" IS NOT NULL
      ORDER BY "bs"."b") as labels, "work_chart".* FROM work_chart WHERE "work_chart"."id" IN (?)
    sql
  end

  # 20 most recent and 20 most popular
  # over the last three months
  def self.frequently_used(user)
    # this code is intentionally not optimal
    # TODO: refactor!
    if Rails.cache.exist? :frequent_charts
      Rails.cache.read :frequent_charts
    else
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
      charts = WorkChart.find ids.map(&:to_i)
      # TODO: implement sweeper!
      Rails.cache.write :frequent_charts, charts, :expires_in => 2.days
      charts
    end
  end

  def labels
    # symbol = "chart_labels_#{self.id}".to_sym
    # if Rails.cache.exist? symbol
    #   Rails.cache.read symbol
    # else

    @labels ||= self["labels"]
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
      # Rails.cache.write symbol, @labels, :expires_in => 2.days
      @labels
  end

  def self.all_with_labels
    # naive implementation - should be refactored!
    if Rails.cache.exist? :charts
      Rails.cache.read :charts
    else
      all = WorkChart.where("parent_id IS NOT NULL AND status = 'active'")
      root = all.where(parent_id: 1).first
      charts = children_for(root, all)
      # TODO: implement sweeper!
      Rails.cache.write :charts, charts, :expires_in => 2.days
      charts
    end
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
