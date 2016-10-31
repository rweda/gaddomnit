ElementSerializer = require "./ElementSerializer"

###
Serializes `<link>` elements by removing the contents and moving the `href` attribute to `opt.linkHref`
###
class LinkSerializer extends ElementSerializer

  ###
  Moves the `href` attribute to the attribute specified by `opt.linkHref`.
  ###
  moveHref: ->
    if @el.hasAttribute "href"
      @el.setAttribute @opt.linkHref, @el.getAttribute "href"
      @el.removeAttribute "href"

  update: ->
    super()
    @moveHref()

module.exports = LinkSerializer
