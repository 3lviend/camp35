WorkChart = require "models/work_chart"

module.exports = class WorkChartsCollection extends Backbone.Collection
  model: WorkChart
  url:   "/work_charts"
