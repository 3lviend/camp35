# pseudo model for fetching report items
class Report

  # returns one tree of report items
  def self.break(from, to, roles)
    # very naive implementation for now
    role_ids = IC::User.where(email: roles).select(:role_id).map(&:role_id)
    grouped = WorkEntry.where(role_id: role_ids).group_by(&:work_chart)
    result = {}
    grouped.each_pair {|k,v| result[k] ||= Interval.new; result[k] = result[k] + (v.inject(Interval.new) {|sum, i| sum += i.total}) }
    items = []
    result.each_pair {|k,v| items << ReportItem.new(k.display_label, v, [])}
    items
  end

end
