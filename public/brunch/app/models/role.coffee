module.exports = class Role extends Backbone.Model

  defaults:
    can_switch_roles: false

  user_name: =>
    @get('display_label').split(":")[1]

  as_label: =>
    if @assumed_other()
      @get('as').split(":")[1]

  assumed_other: =>
    @get('as') != undefined && @get('as') != null

  assume_async: (config) =>
    $.ajax
      url: "/roles/assume.json"
      type: "POST"
      data:
        email: @get('email')
      success: (data) =>
        if config.success
          config.success(data)
      error: (xhr, status, err) =>
        if config.error
          config.error(err)

