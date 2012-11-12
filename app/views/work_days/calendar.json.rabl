collection @days
attributes :date
node :time do |day|
  "#{'%02d' % day.time.hour}:#{'%02d' % day.time.min}:00"
end
node :billable_time do |day|
  "#{'%02d' % day.billable_time.hour}:#{'%02d' % day.billable_time.min}:00"
end
node :nonbillable_time do |day|
  "#{'%02d' % day.nonbillable_time.hour}:#{'%02d' % day.nonbillable_time.min}:00"
end
