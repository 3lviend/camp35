# Helper model for accessing work days
class WorkDay

  attr_accessor :date, :time, :user_id, :billable_time, :nonbillable_time, :has_zero

  def initialize(data = {})
    self.billable_time = Time.parse "00:00:00"
    self.nonbillable_time = Time.parse "00:00:00"
    self.time = Time.parse "00:00:00"
    data.each do |k, v|
      self.send "#{k}=", v
    end
  end

  def self.by_year_and_month(user, year, month)
    first_day = DateTime.new(year.to_i, month.to_i, 1)
    start_range = first_day
    while start_range.wday > 0
      start_range = start_range - 1.day
    end
    last_day = DateTime.new(year.to_i, month.to_i, -1)
    end_range = last_day
    while end_range.wday < 6
      end_range = end_range + 1.day
    end
    db_days = WorkEntry.connection.execute <<-sql
      SELECT not every(duration <> '00:00:00') as has_zero, SUM(duration) as time, date_performed, work_entry_durations.kind_code
      FROM work_entries
      INNER JOIN work_entry_durations
      ON work_entry_id = work_entries.id
      WHERE
      role_id = #{user.system_role_id}
      AND date_performed >= DATE '#{start_range.to_s(:db)}'
      AND date_performed <= DATE '#{end_range.to_s(:db)}'
      GROUP BY date_performed, work_entry_durations.kind_code ORDER BY date_performed;
    sql
    days = {}
    db_days.to_a.each do |d|
      days[d["date_performed"]] = WorkDay.new(has_zero: d["has_zero"] == "t", user_id: user.id, date: d["date_performed"].to_datetime) unless days[d["date_performed"]]
      days[d["date_performed"]].has_zero = true if d["has_zero"] == "t"
      t = Time.parse d["time"]
      if d["kind_code"][/^billable/]
        bt = days[d["date_performed"]].billable_time || Time.parse("00:00:00")
        bt = bt + t.hour.hours
        bt = bt + t.min.minutes
        days[d["date_performed"]].billable_time = bt
      else
        bt = days[d["date_performed"]].nonbillable_time || Time.parse("00:00:00")
        bt = bt + t.hour.hours
        bt = bt + t.min.minutes
        days[d["date_performed"]].nonbillable_time = bt
      end
    end
    days.values.each do |d|
      d.time = d.time + d.billable_time.hour.hours
      d.time = d.time + d.billable_time.min.minutes
      d.time = d.time + d.nonbillable_time.hour.hours
      d.time = d.time + d.nonbillable_time.min.minutes
    end
    days = days.values
    current = start_range# + 1.day
    while current <= last_day || current.wday > 0
      unless days.detect {|d| d.date.year == current.year && d.date.month == current.month && d.date.day == current.day}
        days << WorkDay.new( user_id: user.id, date: current, has_zero: false)
      end
      current = current + 1.day
    end
    days.sort_by(&:date)
  end

  # DB [WorkDay]
  def self.by_user_and_weeks_ago(user, weeks_from_now = 0)
    weeks_from_now = weeks_from_now.nil? ? 0 : weeks_from_now.to_i
    sql = <<-eos
      SELECT SUM(duration) as time, date_performed 
      FROM work_entries 
      INNER JOIN work_entry_durations 
        ON work_entry_id = work_entries.id 
      WHERE 
        role_id = #{user.system_role_id} AND 
        (EXTRACT (WEEK FROM NOW())+52*EXTRACT(YEAR FROM NOW())) - (EXTRACT (WEEK FROM date_performed)+52*EXTRACT(YEAR FROM date_performed)) = #{weeks_from_now || 0} 
      GROUP BY 
        date_performed
    eos
    db_days = WorkEntry.connection.execute(sql).to_a.map do |rwd|
      wd = WorkDay.new
      wd.date = rwd["date_performed"].to_datetime
      wd.time = Time.parse rwd["time"]      
      wd.user_id = user.id
      wd
    end
    # now - in those cases in which we don't have all days we need to fill them with 
    # time equal to zero
    # there can be a situation in which we won't have any day in array
    # so to know any date from given week we have to compute it now
    first_day = db_days.count > 0 ? db_days.first.date.beginning_of_week : (DateTime.now - weeks_from_now.weeks).beginning_of_week
    days = (0..6).to_a.map do |d|
      day = db_days.detect { |dbd| dbd.date.wday == d }
      if day
        day
      else
        wd = WorkDay.new
        wd.date = (first_day + d - 1)
        wd.time = Time.parse "00:00:00"
        wd.user_id = user.id
        wd
      end
    end
    days.reject { |d| d.date > DateTime.now }.sort_by(&:date).reverse
  end

  def to_s
    "WorkDay(date: #{self.date}, time: #{time}, user_id: #{user_id})"
  end

end
