TimesheetApp.Views.Navigation ||= {}

class TimesheetApp.Views.Navigation.TopBarView extends Backbone.View
  template: JST["backbone/templates/navigation/top_bar"]

  initialize: () ->
    @current_role = @options.role
    @current_role.on "change", =>
      @render()
      ko.applyBindings @view, $(".top-bar")[0]
    @view = new TimesheetApp.Views.Navigation.TopBarViewModel(@current_role)

  render: () ->
    unless $(".top-bar").html() != ""
      $(".top-bar").html @template()

      $("#today").click ->
        now = moment(new Date())
        Backbone.history.navigate "/#entries/#{now.year()}/#{now.month() + 1}/#{now.date()}", true
        false
    
      $("#this_month").click ->
        now = moment(new Date())
        Backbone.history.navigate "/#calendar/#{now.year()}/#{now.month() + 1}", true
        false
    
      $("#new_entry").click ->
        now = moment(new Date())
        Backbone.history.navigate "/#entries/#{now.year()}/#{now.month() + 1}/#{now.date()}/new", true
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
  constructor: (role) ->
    @current_role = ko.observable role
    @assume_other = () ->
      window.router.trigger "admin:assume-other"
      false
    @redirect_to_admin = () ->
      window.open "/admin", "_blank"
      false

    @redirect_to_reports = () ->
      Backbone.history.navigate "/#reports", true
      false
 
