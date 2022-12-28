# CHANGES

## Pork 2.1.0 -- 2022-12-28

### Bugs fixed

* `Pork.show_source` can work under frozen literal string mode now.
* Fix picking the right test for the file line number from `ENV['PORK_TEST']`
  (I totally forgot the details for this from 2017, but I think it should
  make it more accurate anyway)
* Ruby 3.2 compatibility fix. (Removed the use of `Random::DEFAULT`)

### Enhancement

* Introduced `Pork::API.around` which will pass the test object to the block,
  and whenever the object is called with `call` it'll run the test. Note that
  if `call` was never called, it'll act like `Pork::API.before` and the test
  will still run unlike RSpec. To skip the test, call `skip` directly.

## Pork 2.0.0 -- 2016-09-10

### Incompatible changes

* `Pork::Executor` is now renamed to `Pork::Suite`, and the new
  `Pork::Executor` would be served as the real executor who's responsible
  for running the test suites!
* `Pork::Executor.execute` would now take a hash as the argument.
* `Pork::Suite.after` would now run in a reverse manner because that would
  serve better as a destructor.

### Enhancement

* `Pork::Suite.desc` would now preserve the original argument being passed to
  `Pork::Suite.describe`, rather than converting it to a string.
* Major internal structure cleanup. Now we don't include everything into the
  context, but use different objects to do different things. For example,
  now we have `Pork::Isolator` to isolate the context.
* Introduced `Pork.execute_extensions` which would be extending to
  `Pork::Executor`. The only extension for it for now is `Pork::Should`.
* Don't crash if `Pork.loaded` was never called.
* Now you could also make assertions in `after` block without triggering
  `Missing assertions` errors.

## Pork 1.5.0 -- 2016-03-10

### Enhancement

* Now it would show loading time between pork was loaded and test started.
  You could tweak the time by using `Pork.loaded`.
* Pork in sequential mode would just use Isolate internally. This would
  reduce the internal complexity.
* Added `PORK_REPORT=progressbar`, using `ruby-progressbar` underneath.

## Pork 1.4.4 -- 2015-11-10

### Bugs fixed

* Now `Pork.protected_exceptions` would not create stat object.
  We should not create it unless we're trying to run a test.

## Pork 1.4.3 -- 2015-10-08

### Enhancement

* Introduced `Pork.protected_exceptions` to protect exceptions aren't
  derived from `StandardError`. Check README for usage.

## Pork 1.4.2 -- 2015-09-23

### Bugs fixed

* Do not extend anything if no `report_extensions` was loaded.

## Pork 1.4.1 -- 2015-07-23

### Enhancement

* Introduced `Expect#approx` for comparing two floating point numbers.

### Bugs fixed

* Removed the extra colon with PORK_REPORT=description.

## Pork 1.4.0 -- 2015-07-18

### Enhancement

* Introduced `Pork.report_mode` and `ENV['PORK_REPORT']`.
* The replicating command for `ENV['PORK_SEED']` is more accurate now.
* Now you can still run test sequentially when `ENV['PORK_TEST']` is set.

### Bugs fixed

* Using `ENV['PORK_TEST']` to specify a describe block would run all
  before/after blocks properly now.

## Pork 1.3.1 -- 2015-06-06

### Enhancement

* Added `pork_description` in the test case so that we could access the
  description for the running test case. To access the full message,
  use `self.class.send(:description_for, "would: #{pork_description}")`.
  Note that this is not a public API yet, and is subject to change.

## Pork 1.3.0 -- 2015-05-24

### Incompatible changes

* `Pork.run` is renamed to `Pork.execute`,
  and `Pork.run` would now do a full run.
* `Pork::Executor.all_tests` would also include paths to describe blocks.

### Enhancement

* Now `describe` could also take a second argument to specify groups.
* `PORK_TEST` could also accept a file path and line number pointing to a
  describe block. Previously only would block would work.

### Bugs fixed

* `Pork.show_source` would never raise SyntaxError anymore.

## Pork 1.2.4 -- 2015-04-25

### Enhancement

* Introduced `Pork.show_source` to print the source of failing tests. Using
  this feature requires `method_source` installed.

### Bugs fixed

* Fixed a potential data race in parallel tests using `should`.

## Pork 1.2.3 -- 2015-04-16

### Enhancement

* Now `would` could take a second argument with `:groups => [:name]`,
  and you could also specifying the groups to run in `PORK_TEST`.
  Checkout README for more information. Input from @mz026

* `PORK_TEST` could also accept a file path without a line number now.

## Pork 1.2.2 -- 2015-03-19

### Enhancement

* Show tests per second and assertions per second as in minitest.

## Pork 1.2.1 -- 2015-03-18

### Bugs fixed

* Fixed that sometimes it cannot find the test because source_location
  sometimes won't use the full path. Always use `File.expand_path` then.
* Properly strip pork backtrace.

## Pork 1.2.0 -- 2015-03-17

### Incompatible changes

* Mutant integration is removed for now. Please let me know if it could
  be integrated without a problem.
* Default mode changed to `:shuffled`, and the original mode renamed to
  `:sequential`.
* Running individual test changed from description to file:line_number.
  Input from @mz026

### Enhancement

* Paths in backtrace would no longer use `.` to indicate current directory.
  Some editor such as Sublime didn't like it.

## Pork 1.1.3 -- 2015-02-04

* Fixed exit status.
* Introduced `require 'pork/more'` for colored output and bottom-up backtrace.
* Introduced `Pork.Rainbows!` for fun.

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
