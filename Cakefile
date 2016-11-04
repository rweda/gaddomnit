_ = require "underscore"
Promise = require "bluebird"
{exec} = require "child-process-promise"
replace = require "replace"

rollup = require "rollup"
commonjs = require "rollup-plugin-commonjs"
coffee = require "rollup-plugin-coffee-script"
nodeResolve = require "rollup-plugin-node-resolve"
uglify = require "rollup-plugin-uglify"
fs = Promise.promisifyAll require "fs-extra"
globAsync = Promise.promisify require "glob"

blade = Promise.promisifyAll require "blade"

option '', '--no-browser', 'Disable targeting the browser (and AMD)'
option '', '--no-node', "Disable targeting Node.js (and CommonJS)"
option '', '--no-bare', "Disable targeting bare JS (iife)"
option '', '--no-universal', "Disable a universal target (UMD)"
option '', '--no-min', "Disable minification"
option '', '--no-partial', "Disable 'partial' builds, which don't include major libraries"

task 'build', "Build Domnit", (opts) ->
  build opts

task 'docs', "Build Docs", (opts) ->
  docs opts

_rolled = {}
roller = (opts={}) ->
  _.defaults opts, {minify: yes, file: 'src/Domnit.coffee', skip: [], paths: {}}
  opts.skip.push mod for path, mod of opts.paths
  return rolled if rolled = _rolled[JSON.stringify opts]
  plugins = [
    coffee()
    nodeResolve
      main: yes
      skip: opts.skip
      extensions: ['.js', '.coffee']
    commonjs
      extensions: ['.js', '.coffee']
      namedExports: opts.paths
  ]
  plugins.push uglify() if opts.minify
  _rolled[JSON.stringify opts] = rollup.rollup
    entry: opts.file
    plugins: plugins

banner = """
  /*
  Gad Domnit v#{require("./package.json").version}
  Copyright 2016 Redwood EDA.  See #{require("./package.json").homepage} for LICENSE.
  */
"""

# Defines common libraries that should be skipped for partial builds
skip = ["bluebird"]

# For UMD/IIFE bundles, defines packages global variables come from.
globals =
  bluebird: "P"

###
Define specific JavaScript files to include for modules.
For instance, `{"node_modules/lodash/dist/lodash.fp.js": "lodash"}` would ensure that `lodash.fp.js` is the file chosen
for the `lodash` module.
###
browserPaths = {}

###
Runs a build format.
@param [Object] opts the Cake options specified
@param [String] format the output format.  One of `amd`, `cjs`, `iife`, `umd`
@param [String] ext the file extension to add to the output file, such as `-browser`.
@param [String] moduleName the global variable to export {Domnit} as
###
buildFormat = (opts, format, ext, paths, moduleName=null) ->
  tasks = []
  tasks.push roller({paths, minify: no}).then (bundle) ->
    bundle.write {moduleName, globals, banner, format, dest: "public/domnit#{ext}.js"}
  unless opts["no-partial"]
    tasks.push roller({paths, minify: no, skip}).then (bundle) ->
      bundle.write {moduleName, globals, banner, format, dest: "public/domnit#{ext}.nolib.js"}
  return Promise.all tasks if opts["no-min"]
  tasks.push roller({paths}).then (bundle) ->
    bundle.write {moduleName, globals, banner, format, dest: "public/domnit#{ext}.min.js"}
  unless opts["no-partial"]
    tasks.push roller({paths, skip}).then (bundle) ->
      bundle.write {moduleName, globals, banner, format, dest: "public/domnit#{ext}.nolib.min.js"}
  Promise.all tasks

_build = null
build = (opts) ->
  return _build if _build
  tasks = []
  unless opts["no-browser"]
    tasks.push buildFormat opts, 'amd', '-browser', browserPaths
  unless opts["no-node"]
    tasks.push buildFormat opts, 'cjs', '-node'
  unless opts["no-bare"]
    tasks.push buildFormat opts, 'iife', '', null, 'Domnit'
  unless opts["no-universal"]
    tasks.push buildFormat opts, 'umd', '-universal', browserPaths, 'Domnit'
  _build = Promise
    .all tasks
    .then ->
      console.log "Compiled successfully."
    .catch (err) ->
      console.log "Error while compiling: #{err}"

###
Render a single blade demonstration file into to the HTML docs.
###
demoDoc = (opts, file) ->
  blade
    .renderFileAsync file, {}
    .then (html) ->
      fs.writeFileAsync file.replace("demo", "docs/demo").replace("blade", "html"), html

###
Render all of the demonstration files into the built docs.
###
docsDemo = (opts) ->
  globAsync "#{__dirname}/demo/*.blade"
    .map (file) ->
      demoDoc opts, file

###
Render API documentation via Codo.
###
docsCodo = (opts) ->
  Promise
    .resolve exec "$(npm bin)/codo --name 'Gad Domnit!' --title 'Gad Domnit Documentation' --private --readme README.md ./src --output ./docs -- CHANGELOG.md"
    .then (res) ->
      console.log res.stderr
      console.log res.stdout
    .then ->
      replace
        regex: "v[0-9]+\.[0-9]+\.[0-9]+(?:-(?:[0-9A-Za-z-]\.?)+)?"
        replacement: "v#{require("./package.json").version}"
        paths: ['docs/']
        recursive: yes
        include: '*.html'
    .error (err) ->
      console.log "Error while updating docs: #{err}"

###
Copy the build output for the docs.
###
docsBuilt = (opts) ->
  build(opts)
    .then ->
      fs.copyAsync "#{__dirname}/public", "#{__dirname}/docs/public", {clobber: yes}

docs = (opts) ->
  Promise.join docsDemo(opts), docsCodo(opts), docsBuilt(opts)
