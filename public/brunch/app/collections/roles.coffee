Role = require '../models/role'

module.exports = class RolesCollection extends Backbone.Collection
  model: Role
