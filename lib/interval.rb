# class handling interval data type found in PostgreSql
class Interval

  attr_accessor :hours, :minutes

  # TODO: implement all this


  def initialize(interval = "00:00:00")
    unless interval.class == DateTime
      @hours, @minutes = interval.split(":").map(&:to_i)
    else
      @hours = interval.hour
      @minutes = interval.min
    end
  end

  def +(right)
    i = Interval.new
    i.hours = self.hours + right.hours
    i.minutes = self.minutes + right.minutes
    if i.minutes > 60
      i.hours += 1
      i.minutes -= 60
    end
    i
  end

  def to_json
    "#{hours}:#{minutes}:00".to_json
  end

end
