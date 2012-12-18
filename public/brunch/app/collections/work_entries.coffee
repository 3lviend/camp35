WorkEntry = require "../models/work_entry"

module.exports = class WorkEntriesCollection extends Backbone.Collection
  model: WorkEntry
  url:   "/work_entries"
