WorkMonth =  require "../models/work_month"

module.exports = class WorkMonthsCollection extends Backbone.Collection
  model: WorkMonth
  url: "/work_months"
