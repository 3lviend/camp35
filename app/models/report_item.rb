# pseudo model holding info about report item
class ReportItem
  attr_accessor :name, :total, :children

  def initialize(name, total, children)
    @name  = name
    @total = total
    @children = children
  end
end
