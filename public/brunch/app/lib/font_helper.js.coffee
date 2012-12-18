# Helper class for working with fonts - measurements etc.

class TimesheetApp.Helpers.FontHelper
  # returns exact width of given string had it been rendered in
  # given html element
  @get_string_width: (context_element, string) ->
    # let's render it really quickly and get this width
    el = $("<span>#{string}</span>")
    $(context_element).append el
    width = el[0].offsetWidth
    el.remove()
    width
