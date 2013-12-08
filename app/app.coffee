###
Domain filtering cli-tool.
###

_ = require "lodash"
async = require "async"
fs = require "fs"
wc = require "flavored-wc"
line_reader = require "line-reader"
WordPOS = require "wordpos"
wordpos = new WordPOS
cli = require("cli").enable "status"
cli.setUsage "domainfilter [OPTIONS] domains-list.txt"


# Run application
exports.run = ->
  cli.parse
    "pattern": ["p", "word matching pattern", "string", "n"]
    "domains": ["d", "allowed domains separated by commas", "string", no]
    "max-length": ["l", "maximum allowed domain length", "number", 0]
    "skip-symbols": ["s", "skip symbols count", "number", 0]
    "matches-file": ["m", "pathname to file for saving matches", "path", "./matches.txt"]
    "others-file": ["o", "pathname to file for saving not matched domains", "path", "./others.txt"]
    "ignore-digits": [no, "ignore digit symbols", "bool", no]
    "include-dashes": [no, "process domains with dashes", "bool", no]

  cli.main (args, options)->
    # Validation
    try
      input_validation args, options
    catch e
      cli.fatal e.message

    # Domains
    if options.domains
      options.domains = options.domains.split ","

    # Init writer
    writer = new Writer options["matches-file"], options["others-file"]

    # Get total lines in file (for progress tracking)
    wc args[0],
      lines: yes
    , (err, counters)->
      total_lines = counters.lines

      current_line = 0
      # Process file
      line_reader.eachLine args[0], (line, last, cb)->

        cli.progress (++current_line / total_lines)

        if last
          cli.progress 1
          cli.ok "Finished! Matches: #{writer.matches_count}, others: #{writer.others_count}."
          return

        # Find domain in line
        domain = find_domain line
        if not domain
          cb() if not last
          return

        # Skip domains with dashes if needed
        if not options["include-dashes"] and ("-" in domain)
          writer.write_other domain
          cb() if not last
          return

        # Skip by length
        if options["max-length"] and (domain.length > options["max-length"])
          writer.write_other domain
          cb() if not last
          return

        # Clear digits if needed
        word = domain.split(".")[0]
        domain_zone = domain.replace "#{word}.", ""
        if word.match /\d/
          if options["ignore-digits"]
            word = word.replace /\d/g, ""
          else
            writer.write_other domain
            cb() if not last
            return

        # Skip by domain
        if options.domains and (domain_zone not in options.domains)
          writer.write_other domain
          cb() if not last
          return

        # Collect all combinations
        iter = word_combination_lazy word, options.pattern.length, options["skip-symbols"]
        results = []
        while true
          res = iter()
          break if not res.result
          if "skip" of res
            res.result.splice res.skip, 1
          results.push res.result

        # Check if any matches
        async.some results, (words, callback)->
          match words, options.pattern, callback
        , (result)->
          if result
            writer.write_match domain
          else
            writer.write_other domain
          cb() if not last


class Writer

  constructor: (@matches_file, @others_file)->
    @others_count = 0
    @matches_count = 0

  write_match: (domain)->
    @matches_count++
    @_write @matches_file, "#{domain}\n"

  write_other: (domain)->
    @others_count++
    @_write @others_file, "#{domain}\n"

  _write: (filename, line)->
    fs.appendFile filename, line, (->)


# Input validation
exports.input_validation = input_validation = (args, options)->
  # Valudate pathname
  throw new Error("You should specify domains list file pathname") if args.length == 0
  # Validate pattern
  throw new Error("You should specify pattern") if options.pattern.length == 0
  throw new Error("You should specify correct pattern") if not options.pattern.match /^[navd]+$/


pos_methods =
  "n": "isNoun"
  "v": "isVerb"
  "a": "isAdjective"
  "d": "isAdverb"

pos_methods_lookup =
  "n": "lookupNoun"
  "v": "lookupVerb"
  "a": "lookupAdjective"
  "d": "lookupAdverb"

exports.match = match = (words, pattern, callback)->
  arr = _.zip [0...pattern.length], pattern.split("")
  async.every arr, (item, cb)->
    [index, pos] = item
    word = words[index]
    wordpos[pos_methods[pos]] word, cb
  , callback


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

  is_ended = no

  # Special cases
  if (words_count == 1) and (skip_count == 0)
    return ->
      return result: false if is_ended
      is_ended = yes
      return result: [base_word]

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
  skip_iteration = 0

  iter = ->
    # If all data was processed
    return result: false if is_ended
    # Special case
    if skip_count and (not skip_counter) and (words_count == 1)
      skip_counter = yes
      return result: [base_word]

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
      return result: false
    result = []
    prev = 0
    for div in divisions
      continue if not div
      result.push base_word[prev...(prev+div)]
      prev += div
    res =
      result: result
    if skip_iteration
      res.skip = skip_iteration - 1
    return res

  return iter