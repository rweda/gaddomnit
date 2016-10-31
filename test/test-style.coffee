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
  <style id="main" type="text/css">
    body {
      height: 1em;
    }
  </script>
</body>
"""

domnit = (window) ->
  new window.Domnit({originalStyle: 'data-originalStyle'}).serialize window.document.body

describe "<style> Serialization", ->
  dom = jsdom
    .envAsync scripts, ["#{__dirname}/../public/domnit.js"],
      virtualConsole: virtualConsole
      features:
        FetchExternalResources: no# ["script", "link"]
    .then domnit

  it "should remove style body", ->
    dom.then (serialized) ->
      serialized.should.not.include "body {"
