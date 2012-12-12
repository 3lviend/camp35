class TimesheetApp.Models.ReportItem extends Backbone.Model

class TimesheetApp.Collections.ReportItemsCollection extends Backbone.Collection
  model: TimesheetApp.Models.ReportItem
  url: "/reports/break.json"

  parse: (items) =>
    @parse_items items

  parse_items: (items) =>
    _.map items, (item) =>
      ri = new TimesheetApp.Models.ReportItem()
      ri.set('name', item.name)
      ri.set('total', item.total)
      ri.set('children', @parse_items(item.children))

