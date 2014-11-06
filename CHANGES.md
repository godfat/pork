# CHANGES

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
