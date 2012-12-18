module.exports = class SwitchRoleView extends Backbone.View
  template: require "../templates/admin/switch_role"

  initialize: ->
    @other_roles = @options.other_roles
    @other_roles.on "reset", => @render()
    @view = new SwitchRoleViewModel
    @other_roles.on "reset", () =>
      @view.roles(@other_roles.models)

  render: ->
    $("#modal").html(@template()).reveal
      closed: () ->
        $("#modal").html ""
    $("#modal .close-reveal-modal").click -> $('#modal').trigger('reveal:close')
    ko.applyBindings(@view, $("#modal")[0])
    false

class SwitchRoleViewModel
  constructor: ->
    @roles = ko.observableArray []
    @assume_role = (role) =>
      console.info "Assuming role of #{role.user_name()}"
      role.assume_async
        success: (data) =>
          Backbone.history.fragment = null
          Backbone.history.navigate(document.location.hash, true)
          window.app.router.current_role.fetch()
          $("#modal").trigger 'reveal:close'
        error: (data) =>
          console.info "implement me"
