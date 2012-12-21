# Extensions for working with numbers

Number::format_money = (prefix) ->
  integers    = Math.floor @
  fractionals = @ * 100 % 100
  symbol = if prefix == false then '' else '$'
  "#{symbol}#{integers}.#{fractionals.toString().pad(2)}"
