###
A base class for serializing elements.  Intended to be extendable.
###
class ElementSerializer

  ###
  @param [Element] el the element that will be serialized.
  @param [Array<String>] children the serialized children
  @param [Object] opt options to configure the action of gaddomnit.
  ###
  constructor: (@el, @children, @opt) ->
    @originalElement = @el
    @el = @el.cloneNode false

  ###
  Saves the `style` attribute under the name defined by `opt.originalStyle`.
  ###
  saveStyle: =>
    return unless @el.hasAttribute "style"
    @el.setAttribute @opt.originalStyle, @el.getAttribute("style")


  ###
  Sets the `style` to the full computed value.
  ###
  serializeStyle: ->
    if @el.currentStyle
      @el.setAttribute "style", @el.currentStyle
    else
      style = getComputedStyle @originalElement
      for prop in style
        @el.style[prop] = style[prop]

  ###
  Modifies `@el` with common modifications.  Intended to be extended by other classes.
  ###
  update: ->
    @saveStyle()
    @serializeStyle()

  ###
  Interweave stringified children with `textContent` of the current element.
  @return [Array<String>] all contents, both stringified children and text
  ###
  interweaveText: ->
    fullText = @originalElement.textContent
    return @children unless fullText
    [interwoven, lastPos] = [[], 0]
    for child, i in @originalElement.children
      next = child.textContent
      continue unless next
      pos = fullText.indexOf next, lastPos
      if pos > 0
        interwoven.push fullText.substring lastPos, pos
        lastPos = pos
      interwoven.push @children[i]
      lastPos += next.length
    interwoven.push fullText.substring lastPos
    interwoven

  ###
  Serializes this element.
  @return {String} the serialized element
  ###
  toString: ->
    @update()
    name = @el.tagName
    attrs = [name]
    @el.innerHTML = @interweaveText().join("")
    @el.outerHTML

module.exports = ElementSerializer
