# Helper model for accessing work days
class WorkDay

  attr_accessor :date, :time, :user_id

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
