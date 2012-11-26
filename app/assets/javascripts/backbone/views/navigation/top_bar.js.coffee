TimesheetApp.Views.Navigation ||= {}

class TimesheetApp.Views.Navigation.TopBarView extends Backbone.View
  template: JST["backbone/templates/navigation/top_bar"]
  assume_template: JST["backbone/templates/navigation/assume"]

  initialize: () ->
    @view = new TimesheetApp.Views.Navigation.TopBarViewModel

  render: () ->
    unless $(".top-bar").html() != ""
      $(".top-bar").html @template()

      $("#assume-other").click =>
        $("#modal").html(@assume_template()).reveal()
        ko.applyBindings(@view, $("#modal")[0])
        false

      $("#today").click ->
        now = moment.utc(new Date())
        Backbone.history.navigate "/#entries/#{now.year()}/#{now.month() + 1}/#{now.date()}", true
        false
    
      $("#this_month").click ->
        now = moment.utc(new Date())
        Backbone.history.navigate "/#calendar/#{now.year()}/#{now.month() + 1}", true
        false
    
      $("#new_entry").click ->
        now = moment.utc(new Date())
        Backbone.history.navigate "/#entries/#{now.year()}/#{now.month() + 1}/#{now.date()}/new", true
        false
    
      $("#admin").click ->
        window.location.replace "/admin"
        false
    
      $("#logout").click ->
        $.ajax
          url: "/users/sign_out"
          type: "DELETE"
          success: =>
            humane.log "Goodbye"
            $("#logout").hide()
            Backbone.history.navigate "/#", true
          error: =>
            # humane.log "Something wrong happened.. Please contact admin"
            # kinda nasty workaround... TODO: fix
            humane.log "Goodbye"
            $("#logout").hide()
            Backbone.history.navigate "/#", true
        false
    


class TimesheetApp.Views.Navigation.TopBarViewModel
  constructor: ->
    @roles = ko.observableArray([
      {display_label: "Kamil"},
      {display_label: "Jon"}
    ])
    @assume_role = (role) =>
      console.info "Assuming role of #{role.display_label}"
