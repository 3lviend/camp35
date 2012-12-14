# pseudo model holding info about report item
class ReportItem
  attr_accessor :total, :chart

  def initialize(total, chart)
    @total = total
    @chart = chart
  end

  # returns array of items with all chart parents and itself
  def explode
    count_totals self._explode
  end

  def _explode
    if self.chart.parent_id == 1
      [self]
    else
      [self, ReportItem.new(self.total, self.chart.parent)._explode].flatten
    end
  end

  # updates parents totals
  def count_totals(items)
    hash = items.inject({}) do |h, item|
      if h[item.chart.id].nil?
        h[item.chart.id] = item
      else
        h[item.chart.id].total += item.total
      end
      h
    end
    hash.values
  end

end
