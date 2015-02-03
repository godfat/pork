# CHANGES

## Pork 1.1.3 -- 2015-02-04

* Fixed exit status.
* Introduced `require 'pork/more'` for colored output and bottom-up backtrace.
* Introduced `Pork.rainbows!` for fun.

## Pork 1.1.2 -- 2015-01-28

* Really fixed passing `ENV['PORK_MODE']=execute`. I should sleep now.

## Pork 1.1.1 -- 2015-01-28

* Fixed passing `ENV['PORK_MODE']=execute`

## Pork 1.1.0 -- 2015-01-28

### Bugs fixed

* Now we can interrupt the tests and still see current report.
* Use `exit!` in `at_exit` to avoid issues.
* Fixed the description order for nested test cases.

### Incompatible changes

* Pork::Parallel.parallel API slightly changed.
* Pork::Isolate.isolate API slightly changed.
* Pork::Isolate.all_tests format changed.
* Mutant::Integration::Pork could be broken now... but it never really works.

### Enhancement

* Accept `ENV['PORK_MODE']` for `Pork.execute_mode`
* Accept `ENV['PORK_SEED']` for setting up srand.
* Accept `ENV['PORK_TEST']` for running a particular test case.
* For failure tests, it would now print the replicating command.

## Pork 1.0.4 -- 2014-12-29

* Make backtrace easier to read by using `.` and `~`.
* Fix parallels mode to detect missing assertions properly.
* Slightly changed `Pork::Stat`. A kinda incompatible change,
  but using `Pork::Stat` should be considered private.

## Pork 1.0.3 -- 2014-12-26

* Fix `Kernel#should` compatibility for JRuby 1.7.18- and Ruby 2.2.0 by
  never assuming ThreadGroup#list would preserve the order.

## Pork 1.0.2 -- 2014-12-09

* Hash difference is much improved. Now it uses `/` to separate keys,
  and use quotes for string keys and colons for symbol keys, so that
  we won't be confused when comparing string hashes and symbol hashes.
  Further more, it would show `<undefined>` for hashes missing a key,
  and `<out-of-bound>` for arrays out of bound. Previously, hash with
  nil values are indistinguishable with hash missing keys.
  Thanks Chun-Yi Liu (@trantorliu).

## Pork 1.0.1 -- 2014-11-21

* Fixed the failure message for hash diff.

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
* Removed `@__pork__desc__` (which is implementation detail anyway)
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
