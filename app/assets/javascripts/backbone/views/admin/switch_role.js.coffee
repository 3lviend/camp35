TimesheetApp.Views.Admin ||= {}

class TimesheetApp.Views.Admin.SwitchUserView extends Backbone.View
  template: JST["backbone/templates/admin/switch_user"]

  initialize: ->
    @other_roles = @options.other_roles
    @view = new TimesheetApp.Views.Admin.SwitchUserViewModel
    @other_roles.on "reset", () =>
      @view.roles(@other_roles.models)

  render: ->
    $("#modal").html(@template()).reveal
      closed: () ->
        $("#modal").html ""
    ko.applyBindings(@view, $("#modal")[0])
    false

class TimesheetApp.Views.Admin.SwitchUserViewModel
  constructor: ->
    @roles = ko.observableArray []
    @assume_role = (role) =>
      console.info "Assuming role of #{role.user_name()}"
      role.assume_async
        success: (data) =>
          Backbone.history.fragment = null
          Backbone.history.navigate(document.location.hash, true)
          $("#modal").trigger 'reveal:close'
        error: (data) =>
          console.info "implement me"
