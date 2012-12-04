collection @entries
attributes :description, :work_chart_label_parts, :id
node :total_duration do |e|
  duration = e.total_duration
  "#{'%02d' % duration.hour}:#{'%02d' % duration.minute}:00"
end

node :total_billable do |e|
  duration = e.total_billable
  "#{'%02d' % duration.hour}:#{'%02d' % duration.minute}:00"
end

node :total_nonbillable do |e|
  duration = e.total_nonbillable
  "#{'%02d' % duration.hour}:#{'%02d' % duration.minute}:00"
end

node :fee_total do |e|
  e.work_entry_fees.inject(0) {|sum, f| sum = sum + f.fee; sum }.to_f
end
