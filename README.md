# Gad Domnit!
Serialize the DOM into a standalone HTML file.

[![Gad Domnit! on NPM](https://img.shields.io/npm/v/gaddomnit.svg)](https://www.npmjs.com/package/gaddomnit)
[![Travis CI Build](https://img.shields.io/travis/rweda/gaddomnit.svg)](https://travis-ci.org/rweda/gaddomnit)
[![MIT Licensed](https://img.shields.io/github/license/rweda/gaddomnit.svg?style=plastic)](https://github.com/rweda/gaddomnit/blob/master/LICENSE)

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
Then call `Domnit#serialize` with an [`Element`](https://developer.mozilla.org/en-US/docs/Web/API/Element) to
serialize, which returns a standalone string representing the element and all it's children.
