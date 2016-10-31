chai = require "chai"
should = chai.should()

###
Test that Domnit can be loaded via RequireJS and CommonJS.
###

describe "Domnit Loading", ->

  for format in ["-universal", "-browser"]
    do (format) ->
      describe "RequireJS loading domnit#{format}.js", ->
        requirejs = require "requirejs"
        Domnit = null

        it "should load", ->
          Domnit = requirejs "#{__dirname}/../public/domnit#{format}.js"

        it "should have Domnit#serialize", ->
          domnit = new Domnit()
          domnit.serialize.should.be.a "function"

  for format in ["-universal", "-node"]
    do (format) ->
      describe "Node loading domnit#{format}.js", ->
        Domnit = null

        it "should load", ->
          Domnit = require "#{__dirname}/../public/domnit#{format}.js"

        it "should have Domnit#serialize", ->
          domnit = new Domnit()
          domnit.serialize.should.be.a "function"
