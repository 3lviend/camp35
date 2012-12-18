WorkDay = require "../models/work_day"

module.exports = class WorkDaysCollection extends Backbone.Collection
  model: WorkDay
  url:   "/work_days/0"
