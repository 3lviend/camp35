DurationKind = require "models/duration_kind"

module.exports = class DurationKindsCollection extends Backbone.Collection
  model: DurationKind
  url:   "/work_charts//duration_kinds.json"
