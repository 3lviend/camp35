# Extensions for working with numbers

Number::format_money = ->
  integers    = Math.floor @
  fractionals = @ * 100 % 100
  "$#{integers}.#{fractionals.toString().pad(2)}"
