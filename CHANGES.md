# CHANGES

## Pork 1.0.0 -- 2014-11-20

### Bugs fixed

* Now exceptions raised in after hook are properly rescued.
* Previously runtime includes loading time, now it only includes
  test running time.

### Incompatible changes

* Internal structure was completed rewritten.
* Simply `require 'pork'` would no longer introduce `Kernel#should`.
  Use `require 'pork/should'` to bring it back. (`require 'pork/auto'`
  would already do this for you)
* Removed @__pork__desc__ (which is implementation detail anyway)
* Renamed `Pork.report_at_exit` to `Pork.autorun`

### Enhancement

* `Pork.autorun` also accepts a flag to enable/disable autorun.
* Introduced `Pork::Expector#expect` to replace `Kernel#should`
* `Kernel#should` is now optional and a wrapper around `Pork::Expector#expect`

* Introduced `Pork::Inspect#diff_hash`. See README.md for
  `Pork.inspect_failure_mode` for detail.
* Introduced `Pork.execute_mode`. See README.md for detail
* Introduced `Pork::Isolate` which allows you to run a specific test.
* Introduced `Pork::Shuffle` which we could run tests in random order.
  See README.md for `Pork.execute_mode` for detail.
* Introduced `Pork::Parallel` which we could run tests in parallel.
  See README.md for `Pork.execute_mode` for detail.

* Introduced `Pork::Executor#pork_stat` to access the current stat from test.
* Introduced mutant integration.

## Pork 0.9.2 -- 2014-11-07

* Pork::Error is now a StandardError instead of an Exception.
  We should all try to avoid using Exception directly, since
  we don't want to interferer with signal handling.

## Pork 0.9.1 -- 2014-07-14

### Bugs fixed

* It would now properly `exit(1)` when there's an error.
* It would now properly search the stashes chain upon `paste`.

### Enhancement

* `Kernel#should` now accepts a second argument for building messages lazily.
* `Should#satisfy` now accepts a second argument for building messages lazily.
* Introduced `Pork.inspect_failure_mode` to switch failure display mode.
* Default `Pork.inspect_failure_mode` to `:auto`, which would display failures
  accordingly.

## Pork 0.9.0 -- 2014-07-11

* First serious release! Bunch of updates. Nearly complete.

## Pork 0.1.0 -- 2014-07-09

* Birthday!
