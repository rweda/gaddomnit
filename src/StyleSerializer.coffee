ElementSerializer = require "./ElementSerializer"

###
Serializes `<style>` elements by removing the contents.
###
class StyleSerializer extends ElementSerializer


  ###
  Removes the content of a script
  ###
  removeBody: ->
    @el.innerHTML = ""

  ###
  Makes sure that {ElementSerializer#toString} doesn't have an innerHTML with style contents.
  ###
  toString: ->
    super()
    @removeBody()
    @el.outerHTML

module.exports = StyleSerializer
