###
Domain filtering cli-tool.
###

_ = require "lodash"
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

    # Validation
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


# Find domain name in string
exports.find_domain = find_domain = (line)->
  res = line.match /[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}/
  return res[0] if res
  return false

exports.word_combination_lazy = word_combination_lazy = (base_word, words_count, skip_count=0)->

  # Special cases
  if (words_count == 1) and (skip_count == 0)
    return (-> return [base_word])

  # Product iterator filter
  filter = (val)->
    sum = _.reduce val, (sum, num)->
      return sum + num
    return (sum == base_word.length)

  # Init product iterator
  lists = []
  for i in [0...words_count]
    lists.push [1...base_word.length]
  prod_iter = product_lazy lists, filter


  skip_counter = no
  is_ended = no
  skip_iteration = 0

  iter = ->
    # If all data was processed
    return false if is_ended
    # Special case
    if skip_count and (not skip_counter)
      skip_counter = yes
      return [base_word]

    divisions = prod_iter()
    if not divisions
      if skip_count
        new_lists = lists[..]
        if skip_iteration <= words_count
          new_lists.splice skip_iteration, 0, [1..skip_count]
          skip_iteration += 1
        else
          skip_count = 0

        prod_iter = product_lazy new_lists, filter
        return iter()
      else
        is_ended = yes
      return false
    result = []
    prev = 0
    for div in divisions
      continue if not div
      result.push base_word[prev...(prev+div)]
      prev += div
    return result

  return iter