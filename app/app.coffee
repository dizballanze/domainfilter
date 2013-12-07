###
Domain filtering cli-tool.
###

cli = require("cli").enable "status"
cli.setUsage "domainfilter [OPTIONS] domains-list.txt"


# Run application
exports.run = ->
  cli.parse
    "pattern": ["p", "word matching pattern", "string", "n"]
    "skip-symbols": ["s", "skip symbols count", "number", 0]
    "matches-file": ["m", "pathname to file for saving matches", "path", "./matches.txt"]
    "others-file": ["o", "pathname to file for saving not matched domains", "path", "other.txt"]
    "ignore-digits": [no, "ignore digit symbols", "bool", no]
    "include-dashes": [no, "process domains with dashes", "bool", no]

  cli.main (args, options)->
    console.log args
    console.log options

    try
      input_validation args, options
    catch e
      cli.fatal e.message


# Input validation
exports.input_validation = input_validation = (args, options)->
  # Valudate pathname
  throw new Error("You should specify domains list file pathname") if args.length == 0
  # Validate pattern
  throw new Error("You should specify pattern") if options.pattern.length == 0
  throw new Error("You should specify correct pattern") if not options.pattern.match /^[navd]+$/


# Lazy cartesian product with filter
exports.product_lazy = product_lazy = (lists, filter)->
  # Arguments validation
  if (not lists?)
    throw new Error("`lists` argument are required")
  if (lists not instanceof Array) or (lists[0] not instanceof Array)
    throw new Error("`lists` argument should be an array of arrays")
  if not filter?
    filter = ()->
      return true
  if (typeof filter != "function")
    throw new Error("`filter` must be a function")

  counters = []
  for l in lists
    counters.push 0
  is_ended = no

  iter = ->

    return false if is_ended

    # Build value by indexes
    value = []
    for list_index, counter of counters
      value.push lists[list_index][counter]

    # Update counters
    for i in [(lists.length-1)..0]
      list = lists[i]
      if counters[i] < (list.length-1)
        counters[i] += 1
        break
      else
        is_ended = yes if i == 0
        counters[i] = 0

    # Use filter
    if not filter(value)
      return iter()

    return value

  return iter