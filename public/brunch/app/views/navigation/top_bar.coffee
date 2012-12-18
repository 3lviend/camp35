module.exports = class TopBarView extends Backbone.View
  template: require "../templates/navigation/top_bar"

  initialize: () ->
    @current_role = @options.role
    @current_role.on "change", =>
      @render()
      ko.applyBindings @view, $(".top-bar")[0]
    @view = new TopBarViewModel(@current_role)

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
            window.router.current_role.clear()
            Backbone.history.navigate "/#", true
          error: =>
            humane.log "Goodbye"
            window.app.current_role.clear()
            $("#logout").hide()
            Backbone.history.navigate "/#", true
        false
    


class TopBarViewModel
  constructor: (role) ->
    @current_role = ko.observable role
    @assume_other = () ->
      window.app.router.trigger "admin:assume-other"
      false
    @redirect_to_admin = () ->
      window.open "/admin", "_blank"
      false

    @redirect_to_reports = () ->
      Backbone.history.navigate "/#reports", true
      false
 
