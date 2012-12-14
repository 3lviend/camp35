# pseudo model for fetching report items
class Report

  # returns one tree of report items
  def self.break(_from, _to, roles)
    from      = DateTime.parse(_from)
    to        = DateTime.parse(_to)
    role_ids  = IC::User.where(email: roles).select(:role_id).map(&:role_id)
    entries   = entries_for(from, to, role_ids)
    items     = items_for entries
    flattened = flatten_items items
    tree      = build_tree :break, flattened
    
    return tree
  end

  def self.entries_for(from, to, role_ids)
    WorkEntry.where "role_id in (?) AND date_performed >= DATE(?) AND date_performed <= DATE(?)", 
                    role_ids, 
                    from.to_s(:db), to.to_s(:db)
  end

  # Takes [WorkEntry] and returns [ReportItem]
  def self.items_for(entries)
    entries.map do |entry|
      ReportItem.new entry.total, entry.work_chart 
    end
  end

  # Takes [ReportItem] and returns [ReportItem]
  # It runs through all items and adds their parents to the list
  def self.flatten_items(items)
    items.map(&:explode).flatten.inject({}) do |h, i|
      if h[i.chart.id].nil?
        h[i.chart.id] = i
      else
        h[i.chart.id].total += i.total
      end
      h
    end.values
  end

  # Takes Symbol, [ReportItem] and returns Tree (ReportItem)
  def self.build_tree(type, items)
    case type
    when :break
      _build_tree items
    end
  end

  def self._build_tree(items, root = nil)
    return [] if items.empty?
    roots, rest = find_roots items, root
    rs = roots.map do |item|
      children = rest.empty? ? [] : _build_tree(rest, item)
      node = { :name => item.chart.display_label, :total => item.total, :children => children }
    end
    roots.each {|r| items.delete r}
    rs
  end

  # every item which chart.parent_id isn't equal to any other chart.id
  # in the array
  def self.find_roots(items, root = nil)
    roots = []
    if root.nil?
      roots = items.select do |item|
        items.none? { |i| item.chart.parent_id == i.chart.id }
      end
    else
      roots = items.select { |i| i.chart.parent_id == root.chart.id }
    end
    [roots, items - roots]
  end

end
