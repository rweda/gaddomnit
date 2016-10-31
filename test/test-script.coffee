chai = require "chai"
should = chai.should()

Promise = require "bluebird"
fs = require "fs"
jsdom = Promise.promisifyAll require "jsdom"
virtualConsole = jsdom.createVirtualConsole().sendTo(console)

###
Contents for script#url are inserted to deal with jsdom: otherwise the jsdom removes the entire script tag.
###
scripts = """
<body>
  <script id="url" type="text/javascript" src="http://rweda.com/">var y = 0;</script>
  <script id="embed" type="text/javascript">
    var x = 1;
  </script>
</body>
"""

domnit = (window) ->
  new window.Domnit({originalStyle: 'data-originalStyle'}).serialize window.document.body

describe "<script> Serialization", ->
  dom = jsdom
    .envAsync scripts, ["#{__dirname}/../public/domnit.js"],
      virtualConsole: virtualConsole
      features:
        FetchExternalResources: no# ["script", "link"]
    .then domnit

  it "should move src attribute", ->
    dom.then (serialized) ->
      serialized.should.not.include " src="
      serialized.should.include "data-originalsrc=\"http://rweda.com/\""

  it "should remove script body", ->
    dom.then (serialized) ->
      serialized.should.not.include "var x"
      serialized.should.not.include "var y"
