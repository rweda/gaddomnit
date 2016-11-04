chai = require "chai"
should = chai.should()

Promise = require "bluebird"
fs = require "fs"
jsdom = Promise.promisifyAll require "jsdom"
virtualConsole = jsdom.createVirtualConsole().sendTo(console)

html = """
<body>
  <link id="url" type="text/css" href="http://rweda.com/" />
  <div id="container">
    <div class="child"></div>
  </div>
</body>
"""

domnit = (opts) ->
  (window) ->
    new window.Domnit(opts).serialize window.document.body

describe "Filtering", ->

  describe "the entire document", ->
    dom = jsdom
      .envAsync html, ["#{__dirname}/../public/domnit.js"],
        virtualConsole: virtualConsole
        features:
          FetchExternalResources: no #["link"]
      .then (window) ->
        opts =
          filter: (el) -> el.tagName is "BODY"
        new window.Domnit(opts).serialize window.document.body

    it "should return an empty string", ->
      dom.then (serialized) ->
        serialized.should.equal ""

  describe "an element with children", ->
    dom = jsdom
      .envAsync html, ["#{__dirname}/../public/domnit.js"],
        virtualConsole: virtualConsole
        features:
          FetchExternalResources: no #["link"]
      .then (window) ->
        opts =
          filter: (el) -> el.id is "container"
        new window.Domnit(opts).serialize window.document.body

    it "should return the container", ->
      dom.then (serialized) ->
        serialized.should.include "<body"

    it "should include other contents", ->
      dom.then (serialized) ->
        serialized.should.include "<link"

    it "should exclude the parent", ->
      dom.then (serialized) ->
        serialized.should.not.include "id=\"container\""

    it "should exclude children", ->
      dom.then (serialized) ->
        serialized.should.not.include "id=\"child\""
