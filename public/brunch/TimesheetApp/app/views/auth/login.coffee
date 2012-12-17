module.exports = class LogInView extends Backbone.View
  template: require "../templates/auth/login"

  render: =>
    $("#main").html(@template())
    $("header.row").html("<h1>Log in</h1><h4>Fill in the form and come aboard!</h4>")
    $("#logout, #today, #new_entry, #admin, #this_month").hide()
    $("#side").html ""
    $(".button.login").click @login
    $("#user_email").focus()
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
      success: (data) =>
        if data.success
          humane.log "Welcome aboard!"
          $(window).oneTime 500, =>
            Backbone.history.navigate "/#", true
        else
          humane.log data.errors
      error: (xhr, status, err) =>
        humane.log err
