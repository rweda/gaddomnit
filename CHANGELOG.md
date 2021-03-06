## Unreleased

### Added
- [Domnit][Domnit#constructor] takes `moveListeners` option, moving all `on[event]` listeners to an alternative field.

## [0.3.1] - 2016-11-07

### Added
- CodeMirror [demonstration][demo:codemirror]
- [Domnit][Domnit#constructor] takes `concurrency` option, limiting how much Domnit blocks other processes.
- [Domnit][Domnit#constructor] takes `nonBlocking` option, requiring Domnit to give up process control.

### Modified
- **[edge-case]** `nonBlocking` defaults to `true`, allowing other actions to take place on the page.  If you depended
  on other actions waiting until Domnit finished, set `nonBlocking` to `false`.

## [0.3.0] - 2016-11-04

### Added
- [Domnit][Domnit#constructor] takes `style` option, to skip evaluating invisible tags.
- [Domnit][Domnit#constructor] takes `filter`, `filterHidden` and `filterDisplayNone` options.
- [Domnit][Domnit#constructor] takes `inheritStyle` and `inheritSilent` options

### Modified
- Moved `jsdom` to the `devDependencies` section.
- Improved performance of non-`useBrowserStyle` requests
- Improved performance of [DefaultStyle.getNoCache] by removing delays and starting promise earlier to improve caching.

## [0.2.0] - 2016-11-04

### Added

#### Features
- Added optional filter to remove default CSS properties to shorten the output.

#### Demos
- Bootstrap demonstration
- Demo Compilation

#### Documentation
- Documented [Domnit#constructor] options

### Modified
- **[breaking]** Changed [ElementSerializer#update] to return a promise
- Bugfix: [ElementSerializer#interweaveText] skipped elements that didn't have `innerHTML`

[Domnit#constructor]: https://rweda.github.io/gaddomnit/#https://rweda.github.io/gaddomnit/class/Domnit.html#constructor-dynamic
[ElementSerializer#update]: https://rweda.github.io/gaddomnit/#https://rweda.github.io/gaddomnit/class/ElementSerializer.html#update-dynamic
[ElementSerializer#interweaveText]: https://rweda.github.io/gaddomnit/#https://rweda.github.io/gaddomnit/class/ElementSerializer.html#interweaveText-dynamic
[DefaultStyle.getNoCache]: https://rweda.github.io/gaddomnit/#https://rweda.github.io/gaddomnit/class/DefaultStyle.html#getNoCache-dynamic
[demo:codemirror]: https://rweda.github.io/gaddomnit/demo/codemirror.html
