TimesheetApp.Views.Authentication ||= {}

class TimesheetApp.Views.Authentication.LoginView extends Backbone.View
  template: JST["backbone/templates/authentication/login"]

  render: =>
    $("#main").html(@template())
    $("header.row").html("<h1>Log in</h1><h4>Fill in the form and come aboard!</h4>")
    $(".button.login").click @login

  login: =>
    $.ajax
      url: "/users/sign_in.json"
      type: "POST"
      data:
        user:
          email: $("#user_email").val()
          password: $("#user_password").val()
          remember_me: 1
        utf8: "✓"
        remote: true
      success: (data) =>
        if data.success
          humane.log "Welcome aboard!"
          window.location.replace "/"
          #Backbone.history.navigate "/#", true
        else
          humane.log data.errors
      error: (xhr, status, err) =>
        humane.log err
