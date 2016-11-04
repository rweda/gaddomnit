DefaultStyle = require "./DefaultStyle"
Promise = require "bluebird"

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
    if @opt.style?[@el.tagName.toLowerCase()] is no
      @el.removeAttribute "style"
      return Promise.resolve()
    if @el.currentStyle
      @el.setAttribute "style", @originalElement.currentStyle
    else if @opt.useBrowserStyle
      DefaultStyle
        .get @el.tagName
        .then (def) =>
          style = getComputedStyle @originalElement
          for prop in style when style[prop] isnt def[prop]
            @el.style[prop] = style[prop]
    else
      @el.style.cssText = getComputedStyle(@originalElement).cssText

  ###
  Modifies `@el` with common modifications.  Intended to be extended by other classes.
  @return {Promise} resolves when done updating
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
      unless next
        interwoven.push @children[i]
        continue
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
    Promise
      .resolve @update()
      .then =>
        name = @el.tagName
        attrs = [name]
        @el.innerHTML = @interweaveText().join("")
        @el.outerHTML

module.exports = ElementSerializer
