# Helper class containing useful methods for working with tabulat data

class TimesheetApp.Helpers.TableHelper
  # given a table cell align time interval in this cell 
  # to dot char
  @align_interval: (cell) ->
    @align_interval_to(cell, cell)

  @align_interval_to: (reference_cell, cell) ->
    return if $(cell).attr("data-aligned") == "true"
    [s_hours, s_minutes] = $(cell).text().split(".")
    return if s_minutes.length == 2

    # we are cheating here: intervals can either have .0 or .xx
    # minutes in our app so we just need to add a little padding
    # to those values that have .0 minutes
    #
    # then even that we don't use monospaced font - the overall
    # effect will be quite good anyway

    width = TimesheetApp.Helpers.FontHelper.get_string_width(reference_cell, "0")
    current_padding = parseInt $(cell).css("padding-right"), 10
    $(cell).css("padding-right", current_padding + width)
    $(cell).attr("data-aligned", true)

