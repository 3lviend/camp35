# class wrapping Zurb reveal modal window functionality

class TimesheetApp.Modal
  constructor: (selector) ->
    @selector = selector

  show: (config = {}) =>
    if config.content
      $(@selector).html config.content
    $(@selector).reveal
      closed: config.closed
    window.scroll_top()
    $('body').off( 'keyup.reveal')
