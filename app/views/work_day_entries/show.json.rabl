collection @entries
attributes :description, :work_chart_label_parts, :id
node :total_duration do |e|
  duration = e.total_duration
  "#{'%02d' % duration.hour}:#{'%02d' % duration.minute}:00"
end
