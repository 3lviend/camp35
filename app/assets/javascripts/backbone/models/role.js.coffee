
class TimesheetApp.Models.Role extends Backbone.Model

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

class TimesheetApp.Collections.RolesCollection extends Backbone.Collection
  model: TimesheetApp.Models.Role
