###
Test domain_find
###


describe "Find domain", ->

  TEST_LINES = [
    "23edgwypmi.asia,12/4/2013 12:00:00 AM,AUC"
    "1and1app.com,12/4/2013 12:00:00 AM,AUC"
    "crackfacts.com,12/4/2013 12:00:00 AM,AUC"
    "dali-loco.com,12/4/2013 12:00:00 AM,AUC"
  ]
  EXPECTED_RESULTS = [
    "23edgwypmi.asia"
    "1and1app.com"
    "crackfacts.com"
    "dali-loco.com"
  ]

  app = require "../app/app"
  find_domain = app.find_domain

  it "should have `find_domain` function", ->
    app.should.have.property "find_domain"
    app.find_domain.should.have.type "function"

  it "should find domain in string and return it", ->
    for index, line of TEST_LINES
      domain = find_domain line
      domain.should.be.eql EXPECTED_RESULTS[index]

  it "should return false if no domain was founded", ->
    find_domain("test,com,test--line.c,worng_domain.n").should.be.false