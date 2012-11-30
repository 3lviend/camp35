# Extensions to the String object adding few methods
# helping with formatting time interval strings

# Tries to parse given string checking for 00:00 format
# or 00h 00m and returns 0.0 as result.
# Throws exception if parsing isn't successfullOB
#
# String -> String
String::format_interval = -> @to_interval().to_s('decimal')

# Tries to parse given string and returns TimeInterval
# object.
# Throws exception when paring unsuccessful
# OA
# String -> TimeInterval
String::to_interval = ->
  split_on = if /^\d{1,9}:\d{1,2}(:\d{1,2}){0,1}$/.test @
    ":"
  else if /^\d{1,9}h\s\d{1,2}m$/.test @
    " "
  else
    throw "Unsupported time interval string: #{@}"
  [hours, minutes] = @.split split_on
  new TimesheetApp.Helpers.TimeInterval(parseInt(hours, 10), parseInt(minutes, 10))

String::pad = (num) ->
  n = parseInt @, 10
  to_slice = if @.length > num then @.length else num
  String(Array(num).join("0") + n).slice(-1 * to_slice)

String::pagedown = ->
  converter = Markdown.getSanitizingConverter()
  converter.makeHtml @
