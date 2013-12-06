###
Domain filtering cli-tool.
###

cli = require "cli"
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
    console.log(args);
    console.log(options);