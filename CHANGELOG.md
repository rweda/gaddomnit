## [Unreleased]

### Added

#### Features
- Added optional filter to remove default CSS properties to shorten the output.

#### Demos
- Bootstrap demonstration
- Demo Compilation

#### Documentation
- Documented [Domnit#constructor] options

### Modified
- **[breaking]** Changed [Domnit#update] to return a promise
- Bugfix: [ElementSerializer#interweaveText] skipped elements that didn't have `innerHTML`
