ElementSerializer = require "./ElementSerializer"

###
Serializes `<script>` elements by removing the contents and moving the `src` attribute to `opt.originalSrc`
###
class ScriptSerializer extends ElementSerializer

  ###
  Moves the `src` attribute to the attribute specified by `opt.originalSrc`.
  ###
  moveSrc: ->
    if @el.hasAttribute "src"
      @el.setAttribute @opt.originalSrc, @el.getAttribute "src"
      @el.removeAttribute "src"

  ###
  Removes the content of a script
  ###
  removeBody: ->
    @el.innerHTML = ""

  ###
  Makes sure that {ElementSerializer#toString} doesn't have an innerHTML with script contents.
  ###
  toString: ->
    super()
      .then =>
        @moveSrc()
        @removeBody()
        @el.outerHTML

module.exports = ScriptSerializer
