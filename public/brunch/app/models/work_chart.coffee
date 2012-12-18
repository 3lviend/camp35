module.exports = class WorkChart extends Backbone.Model
  url: =>
    "/work_charts/#{@id}.json"

