# Gad Domnit!
Serialize the DOM into a standalone HTML file.

[![Gad Domnit! on NPM](https://img.shields.io/npm/v/gaddomnit.svg)](https://www.npmjs.com/package/gaddomnit)
[![Travis CI Build](https://img.shields.io/travis/rweda/gaddomnit.svg)](https://travis-ci.org/rweda/gaddomnit)
[![MIT Licensed](https://img.shields.io/github/license/rweda/gaddomnit.svg)](https://github.com/rweda/gaddomnit/blob/master/LICENSE)

If you've ever wanted to save an exact copy of a webpage, Gad Domnit is for you.
Gad Domnit serializes the exact content on a webpage, retaining an inspectable DOM.

## Features

**Removes Dependencies** All dynamic resources (`<script>`, `<link>`) are changed to prevent them from modifying the
document.

| DOM | Serialized |
| --- | ---------- |
| `<script src="main.js"></script>` | `<script data-originalSrc="main.js"></script>` |

**Computes Style** The style of each element is computed and saved, ensuring that content is styled the same when
opened.

| DOM | Serialized |
| --- | ---------- |
| `<style>div {height: 2em;}</style> <div style="width: 50%"></div>` | `<style></style> <div style="height: 2em; width: 50%;" data-originalStyle="width: 50%;"></div>` |

**Extendable** Domnit is written in modular, object-oriented code.  The existing functionality can be easily changed,
and new modifications can be added.

```coffee
Domnit = require "gaddomnit"
ElementSerializer = Domnit.ElementSerializer
count = 0
class DivSerializer extends ElementSerializer
  update: ->
    super()
    this.el.addAttribute "data-count", ++count

class MySerializer extends Domnit
  divSerializer: DivSerializer
```
(Yes, that's a complete example.)

## Installation

Install `gaddomnit` via [NPM](https://www.npmjs.com/) or directly from [RawGit](http://rawgit.com/):

```html
<script src="https://cdn.rawgit.com/rweda/gaddomnit/v0.0.1/public/domnit-universal.min.js"></script>
```

The `universal` build should work as a standalone script, via RequireJS, or via CommonJS/NPM.
It bundles all of the dependencies, and should work out of the box.

Alternatively, specify `-browser` to only get RequireJS syntax, `-node` for only CommonJS, or no suffix at all to get
a raw script without any loader.

Add `.nolib` immediately after the syntax specification to load dependencies via RequireJS/CommonJS (or browser globals
if you aren't using a module loader).

## Usage

```js
// require(["domnit"], function(Domnit) {
// Domnit = require("gaddomnit");

var domnit = new Domnit({});
domnit.serialize(document.body);
// -> "<body style='display: block'>...</body>"
```

After loading Domnit, create a new Domnit object, optionally passing an object with configuration options.
Then call [`Domnit#serialize`][Domnit#serialize] with an [`Element`](https://developer.mozilla.org/en-US/docs/Web/API/Element) to
serialize, which returns a standalone string representing the element and all it's children.

See [`Domnit`][Domnit] class documentation for the full API as well as information on extending Domnit's features.

[Domnit]: https://rweda.github.io/gaddomnit/#https://rweda.github.io/gaddomnit/class/Domnit.html
[Domnit#serialize]: https://rweda.github.io/gaddomnit/#https://rweda.github.io/gaddomnit/class/Domnit.html#serialize-dynamic
