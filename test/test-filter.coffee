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
  <div id="invisible", style="visibility: hidden;">
    <div id="invisible2"></div>
  </div>
  <div id="dispNone", style="display: none;">
    <div id="dispNone2"></div>
  </div>
</body>
"""

init = (opts) ->
  dom = jsdom
    .envAsync html, ["#{__dirname}/../public/domnit.js"],
      virtualConsole: virtualConsole
      features:
        FetchExternalResources: no
    .then (window) ->
      new window.Domnit(opts).serialize window.document.body

domnit = (opts) ->
  (window) ->
    new window.Domnit(opts).serialize window.document.body

describe "Filtering", ->

  describe "the entire document", ->
    dom = init
      filter: (el) -> el.tagName isnt "BODY"

    it "should return an empty string", ->
      dom.then (s) -> s.should.equal ""

  describe "an element with children", ->
    dom = init
      filter: (el) -> el.id isnt "container"

    it "should return the container", ->
      dom.then (s) -> s.should.include "<body"

    it "should include other contents", ->
      dom.then (s) -> s.should.include "<link"

    it "should exclude the parent", ->
      dom.then (s) -> s.should.not.include "id=\"container\""

    it "should exclude children", ->
      dom.then (s) -> s.should.not.include "class=\"child\""

describe "Filter Shortcuts", ->

  describe "with default options", ->
    dom = init()

    it "should include elements with 'visibility: hidden;'", ->
      dom.then (s) -> s.should.include "id=\"invisible\""

    it "should include the children of elements with 'visibility: hidden;'", ->
      dom.then (s) -> s.should.include "id=\"invisible2\""

    it "should include elements with 'display: none;'", ->
      dom.then (s) -> s.should.include "id=\"dispNone\""

    it "should include children of elements with 'display: none;'", ->
      dom.then (s) -> s.should.include "id=\"dispNone2\""

  describe "with filterHidden", ->
    dom = init {filterHidden: yes}

    it "should not include elements with 'visibility: hidden;'", ->
      dom.then (s) -> s.should.not.include "id=\"invisible\""

    it "should not include the children of elements with 'visibility: hidden;'", ->
      dom.then (s) -> s.should.not.include "id=\"invisible2\""

    it "should include elements with 'display: none;'", ->
      dom.then (s) -> s.should.include "id=\"dispNone\""

    it "should include children of elements with 'display: none;'", ->
      dom.then (s) -> s.should.include "id=\"dispNone2\""

  describe "with filterDisplayNone", ->
    dom = init {filterDisplayNone: yes}

    it "should include elements with 'visibility: hidden;'", ->
      dom.then (s) -> s.should.include "id=\"invisible\""

    it "should include the children of elements with 'visibility: hidden;'", ->
      dom.then (s) -> s.should.include "id=\"invisible2\""

    it "should not include elements with 'display: none;'", ->
      dom.then (s) -> s.should.not.include "id=\"dispNone\""

    it "should not include children of elements with 'display: none;'", ->
      dom.then (s) -> s.should.not.include "id=\"dispNone2\""
