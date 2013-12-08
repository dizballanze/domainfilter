###
Lazy generate word combination from string
###


describe "Lazy word combination", ->

  TEST_WORD_1 = "hello"
  TEST_WORD_2 = "myday"
  TEST_WORD_3 = "ieatbit"

  _ = require "lodash"
  app = require "../app/app"
  word_combination_lazy = app.word_combination_lazy

  it "should have function", ->
    app.should.have.property "word_combination_lazy"
    app.word_combination_lazy.should.have.type "function"

  it "should return function", ->
    word_combination_lazy(TEST_WORD_1, 1).should.have.type "function"

  it "should return correct words (1 words count)", ->
    iter = word_combination_lazy TEST_WORD_1, 1
    iter().result.should.be.eql [TEST_WORD_1]

  it "should return correct words (2 words count)", ->
    expected = ["m,yday","my,day","myd,ay","myda,y"]
    iter = word_combination_lazy TEST_WORD_2, 2
    results = []
    for i in [0...expected.length]
      res = iter().result
      results.push "#{res[0]},#{res[1]}"
    diff = _.difference expected, results
    diff.should.have.length 0

  it "should return correct words (3 words count)", ->
    expected = ["i,e,atbit","i,ea,tbit","i,eat,bit","i,eatb,it","i,eatbi,t","ie,a,tbit",
                "ie,at,bit","ie,atb,it","ie,atbi,t","iea,t,bit","iea,tb,it","iea,tbi,t",
                "ieat,b,it","ieat,bi,t","ieatb,i,t"]
    iter = word_combination_lazy TEST_WORD_3, 3
    results = []
    for i in [0...expected.length]
      res = iter().result
      results.push "#{res[0]},#{res[1]},#{res[2]}"
    diff = _.difference expected, results
    diff.should.have.length 0


  it "should return correct words (1 words count, skip=3)", ->
    expected = [
      "hello"
      "h,ello"
      "hell,o"
      "he,llo"
      "hel,lo"
      "hel,lo"
    ]
    iter = word_combination_lazy TEST_WORD_1, 1, 3
    results = []
    while true
      res = iter().result
      break if not res
      results.push res.join(",")
    diff = _.difference expected, results
    diff.should.have.length 0

  it "should return correct words (2 words count, skip=1)"
  it "should return correct words (3 words count, skip=2)"
  it "should return `false` if all data was processed", ->
    iter = word_combination_lazy TEST_WORD_3, 3
    for i in [0...15]
      iter().should.be.ok
    iter().result.should.be.false
    iter().result.should.be.false