TimesheetApp.Views.Authentication ||= {}

class TimesheetApp.Views.Authentication.LoginView extends Backbone.View
  template: JST["backbone/templates/authentication/login"]

  render: =>
    $("#main").html(@template())
    $("header.row").html("<h1>Log in</h1><h4>Fill in the form and come aboard!</h4>")
    $("#logout, #today, #new_entry, #admin, #this_month").hide()
    $("#side").html ""
    $(".button.login").click @login
    $("#new_user input").keypress (e) =>
      if e.keyCode == 13 && !e.shiftKey
        @login()
        false

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
          $("#today, #new_entry, #logout, #admin").show()
          window.location.replace "/"
          #Backbone.history.navigate "/#", true
        else
          humane.log data.errors
      error: (xhr, status, err) =>
        humane.log err
