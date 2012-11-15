class WorkMonth
  attr_accessor :year, :month, :user_id, :billable_total, :nonbillable_total, :available, :total

  # naive implementation - subject to refactor and performance tuning later
  def self.find_by_range(user, start, _end)
    current = _end
    months = []
    while current >= start
      days = WorkDay.by_year_and_month(user, current.year, current.month).select {|d| d.date.month == current.month}
      puts days
      billable_total = days.map(&:billable_time).inject({:h => 0, :m => 0}) {|m,t| m[:h] = m[:h] + t.hour; m[:m] = m[:m] + t.min; m }
      nonbillable_total = days.map(&:nonbillable_time).inject({:h => 0, :m => 0}) {|m,t| m[:h] = m[:h] + t.hour; m[:m] = m[:m] + t.min; m }
      total = {h: billable_total[:h] + nonbillable_total[:h], m: billable_total[:m] + nonbillable_total[:m]}
      available = days.map(&:date).reject {|d| d.wday == 0 || d.wday == 6 }.count * 8
      m= WorkMonth.new
      m.user_id = user.id
      m.available = available
      puts billable_total
      puts nonbillable_total
      m.billable_total = "#{billable_total[:h] + (billable_total[:m] / 60)}h #{billable_total[:m] % 60}m"
      m.nonbillable_total = "#{nonbillable_total[:h] + (nonbillable_total[:m] / 60)}h #{nonbillable_total[:m] % 60}m"
      m.total = "#{total[:h] + (total[:m] / 60)}h #{total[:m] % 60}m"
      m.year = current.year
      m.month = current.month
      months << m
      current = current - 1.month
    end
    months
  end
end
