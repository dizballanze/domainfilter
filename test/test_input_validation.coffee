###
Input validation.
###


describe "Input validation", ->

  TEST_ARGS = ["test.txt"]

  TEST_CORRECT_PARAMS =
    "pattern": "n",
    "skip-symbols": 0,
    "matches-file": "./matches.txt",
    "others-file": "other.txt",
    "ignore-digits": false,
    "include-dashes": false

  _ = require "lodash"
  app = require "../app/app"
  input_validation = app.input_validation

  it "should gave input_validation function", ->
    app.should.have.property "input_validation"
    app.input_validation.should.have.type "function"

  describe "pattern validation", ->

    it "should be specified", ->
      params = _.clone TEST_CORRECT_PARAMS
      params.pattern = ""
      (->
        input_validation TEST_ARGS, params
      ).should.throw /pattern/

    it "should check format", ->
      params = _.clone TEST_CORRECT_PARAMS
      params.pattern = "xyz"
      (->
        input_validation TEST_ARGS, params
      ).should.throw /correct\spattern/

    it "should accept correct patter", ->
      params = _.clone TEST_CORRECT_PARAMS
      params.pattern = "vnad"
      (->
        input_validation TEST_ARGS, params
      ).should.not.throw()

  describe "validate args", ->

    it "should validate that domains file was specified", ->
      (->
        input_validation [], TEST_CORRECT_PARAMS
      ).should.throw /domains/