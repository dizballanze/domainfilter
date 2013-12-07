###
Test cartesian product.
###


describe "Cartesian product", ->

  TEST_EXPECTED = ["1, 1", "1, 2", "1, 3", "2, 1", "2, 2", "2, 3", "3, 1", "3, 2", "3, 3"]

  _ = require "lodash"
  app = require "../app/app"
  product_lazy = app.product_lazy

  it "should have product function", ->
    app.should.have.property "product_lazy"
    app.product_lazy.should.have.type "function"

  it "should raise exception on wrong arguments", ->
    (->
      product_lazy()
    ).should.throw()
    (->
      product_lazy 123, ()->
    ).should.throw()
    (->
      product_lazy [[]], 123
    ).should.throw()

  it "should return function", ->
    product_lazy([[]]).should.have.type "function"

  it "should return correct products (2 lists)", ->
    iter = product_lazy [[1,2,3], [1,2,3]]
    results = []
    for i in [0...(TEST_EXPECTED.length)]
      res = iter()
      results.push "#{res[0]}, #{res[1]}"
    diff = _.difference TEST_EXPECTED, results
    diff.should.have.length 0

  it "should return correct products (3 lists)", ->
    expected = ["1, 4, 7", "1, 4, 8", "1, 4, 9", "1, 5, 7", "1, 5, 8", "1, 5, 9", "1, 6, 7",
                "1, 6, 8", "1, 6, 9", "2, 4, 7", "2, 4, 8", "2, 4, 9", "2, 5, 7", "2, 5, 8",
                "2, 5, 9", "2, 6, 7", "2, 6, 8", "2, 6, 9", "3, 4, 7", "3, 4, 8", "3, 4, 9",
                "3, 5, 7", "3, 5, 8", "3, 5, 9", "3, 6, 7", "3, 6, 8", "3, 6, 9"]
    iter = product_lazy [[1,2,3], [4,5,6], [7,8,9]]
    results = []
    for i in [0...(expected.length)]
      res = iter()
      results.push "#{res[0]}, #{res[1]}, #{res[2]}"
    diff = _.difference expected, results
    diff.should.have.length 0


  it "should return `false` if all calculations was performed", ->
    iter = product_lazy [[1,2,3], [1,2,3]]
    iter() for i in [0...(TEST_EXPECTED.length)]
    iter().should.not.be.ok

  it "should call filter on each result", ->
    counter = 0
    filter = ->
      counter++
    iter = product_lazy [[1,2,3], [1,2,3]], filter
    iter() for i in [0...(TEST_EXPECTED.length)]
    counter.should.be.eql TEST_EXPECTED.length

  it "should filter results", ->
    filter = (el)->
      return (el[0] + el[1]) % 2 == 0
    iter = product_lazy [[1,2,3], [1,2,3]], filter
    counter = 0
    while res = iter()
      (((res[0] + res[1]) % 2) == 0).should.be.true
      counter++
    counter.should.be.eql 5