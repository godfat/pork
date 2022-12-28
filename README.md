# Pork [![Pipeline status](https://gitlab.com/godfat/pork/badges/master/pipeline.svg)](https://gitlab.com/godfat/pork/-/pipelines)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/pork)
* [rubygems](https://rubygems.org/gems/pork)
* [rdoc](http://rdoc.info/github/godfat/pork)
* [issues](https://github.com/godfat/pork/issues) (feel free to ask for support)

## DESCRIPTION:

Pork -- Simple and clean and modular testing library.

Inspired by [Bacon][].

[Bacon]: https://github.com/chneukirchen/bacon

## DESIGN:

* Consistency over convenience.
* Avoid polluting anything by default to make integration easier.
* The less codes the better.

## WHY?

[Bacon][] has some issues which can't be easily worked around. For example,
the context of the running test is not consistent in nested describe block.

This won't work in Bacon:

``` ruby
require 'bacon'
Bacon.summary_on_exit

# This would include to all context,
# so that we don't have to include in all describe block.
Bacon::Context.include Module.new{
  def in_module
    object_id
  end
}

describe 'A' do
  def in_describe
    object_id
  end

  describe 'B' do
    should 'have the same context' do
      in_module.should == in_describe # FAIL!
    end
  end
end
```

But this works in Pork:

``` ruby
require 'pork/auto'

describe 'A' do
  include Module.new{
    def in_module
      object_id
    end
  }

  def in_describe
    object_id
  end

  describe 'B' do
    would 'have the same context' do
      in_module.should == in_describe
    end

    def in_nested_describe
      object_id
    end

    would 'respond_to? in_nested_describe' do
      should.respond_to?(:in_nested_describe)
    end
  end

  # Pork is completely tree structured, nested methods can't be accessed
  # from outside of the scope.
  would 'not respond_to? in_nested_describe' do
    should.not.respond_to?(:in_nested_describe)
  end
end

describe 'C' do
  # Also, we're not forced to include something in all describe blocks.
  # If we want, we could do this instead: `Pork::Suite.include(Module.new)`
  # That would be the same as including in `Bacon::Context`
  would 'not respond_to? in_module nor in_describe' do
    should.not.respond_to?(:in_module)
    should.not.respond_to?(:in_describe)
  end
end
```

Also, Bacon won't clear instance variables as well.

``` ruby
require 'bacon'
Bacon.summary_on_exit

describe 'instance variables in tests' do
  before do
    @a ||= 0
    @a  += 1
  end

  should 'always be 1' do
    @a.should == 1
  end

  should 'always be 1' do
    @a.should == 1 # FAIL!
  end
end
```

Every tests would be a whole new instance for Pork as expected:

``` ruby
require 'pork/auto'

describe 'instance variables in tests' do
  before do
    @a ||= 0
    @a  += 1
  end

  would 'always be 1' do
    @a.should == 1
  end

  would 'always be 1' do
    @a.should == 1
  end
end
```

## REQUIREMENTS:

* Tested with MRI (official CRuby) and JRuby.
* (Optional) [method_source][] if you would like to print the source for the
  failing tests.
* (Optional) [ruby-progressbar][] if you like porgressbar for showing
  progress. Checkout [Pork.report_mode](#porkreport_mode) for using it.

[method_source]: https://github.com/banister/method_source
[ruby-progressbar]: https://github.com/jfelchner/ruby-progressbar

## INSTALLATION:

    gem install pork

## SYNOPSIS:

A simple example:

``` ruby
require 'pork/auto'

describe Array do
  before do
    @array = []
  end

  after do
    @array.clear
  end

  would 'be empty' do
    @array.should.empty?
    @array.should.not.include? 1
  end

  would 'have zero size' do
    # We prefer `eq` here over `==` to avoid warnings from Ruby
    @array.size.should.eq 0
  end

  would 'raise IndexError for fetching from non-existing index' do
    should.raise(IndexError){ @array.fetch(0) }.message.
      should.match(/\d+/)

    # Alternatively:
    lambda{ @array.fetch(0) }.should.raise(IndexError).message.
      should.match(/\d+/)
  end
end
```

Copy and paste for modularity:

``` ruby
require 'pork/auto'

copy 'empty test' do |error|
  after do
    @data.clear
  end

  would 'be empty' do
    @data.should.empty?
    @data.should.not.include? 1
  end

  would 'have zero size' do
    # We prefer `eq` here over `==` to avoid warnings from Ruby
    @data.size.should.eq 0
  end

  would "raise #{error} for fetching from non-existing index" do
    should.raise(error){ @data.fetch(0) }.message.
      should.match(/\d+/)

    # Alternatively:
    lambda{ @data.fetch(0) }.should.raise(error).message.
      should.match(/\d+/)
  end
end

describe Array do
  before do
    @data = []
  end

  paste 'empty test', IndexError
end

describe Hash do
  before do
    @data = {}
  end

  paste 'empty test', KeyError
end
```

Context sensitive paste:

``` ruby
require 'pork/auto'

copy 'empty test' do |error|
  paste :setup_data # it would search from the pasted context

  would "raise #{error} for fetching from non-existing index" do
    should.raise(error){ @data.fetch(0) }.message.
      should.match(/\d+/)
  end
end

describe Array do
  copy :setup_data do
    before do
      @data = []
    end
  end

  paste 'empty test', IndexError
end

describe Hash do
  copy :setup_data do
    before do
      @data = {}
    end
  end

  paste 'empty test', KeyError
end
```

## What if I don't want any monkey patches?

For the lazies and the greatest convenience but the least flexibility, we
could simply `require 'pork/auto'` and everything above should work.
However, as you can see, there are some monkey patches around, and you
might not want to see any of them. In this case *DON'T* require it.

Here's what `require 'pork/auto'` would do:

``` ruby
require 'pork'
require 'pork/should'
require 'pork/more'
extend Pork::API
Pork.autorun
```

Here it `require 'pork/should'`, and it would load the monkey patches for
inserting `Kernel#should` shown in SYNOPSIS. This is actually optional,
and could be replaced with `Pork::Suite#expect`. For example, we could
also write it this way:

``` ruby
require 'pork'

Pork::API.describe Array do
  before do
    @array = []
  end

  after do
    @array.clear
  end

  would 'be empty' do
    expect(@array).empty?
    expect(@array).not.include? 1
  end
end

# or: Pork.autorun
Pork::Executor.execute.report
```

As you can see, this way we no longer use any monkey patches and we don't
even use `at_exit` hook to run tests. Also note that we could turn autorun
off by passing `false` to it:

``` ruby
Pork.autorun(false)
```

We might need to turn autorun off occasionally, for example, we do need to
turn this off when integrating [mutant][]. Passing `true` again to `autorun`
could re-enable it.

[mutant]: https://github.com/mbj/mutant

Also note that there's a number of plugins would be loaded upon:

``` ruby
require 'pork/more'
```

## Where's the pork command?

It's not implemented. No strong reasons. You could simply run the tests by
requiring the files defining tests, or execute them directly, with autorun
enabled. (by `require 'pork/auto'` or call `Pork.autorun`)

Here's a example command to require all test files and automatically run them.
With [Fish shell][]:

    ruby -Ilib -rpork/auto -r(ls ./test/test_*.rb) -e ''

Or

    ruby -Ilib -rpork/auto -r(find ./test -name '*.rb' -type f) -e ''

With Bash shell:

    ruby -Ilib -rpork/auto $(ls ./test/test_*.rb | awk '{print "-r" $0}') -e ''

Personally I have a [rake task][gemgem] which would do this for me, so I just
run `rake test` to run all the tests.

[Fish shell]: http://fishshell.com/
[gemgem]: https://github.com/godfat/gemgem

## The API

### Kernel#should

All the assertions begin with `should`. Whenever we called `should` on an
object, it would create an `Pork::Should` object which would verify the
assertion we make. For the simplest case, this verifies if `1 == 1`:

``` ruby
require 'pork/auto'

would{ 1.should.eq 1 }
```

Sometimes we would also want to have a customized message if the assertion
failed, as in `assert_equal 1, 1, 'the message'`, we pass the message as the
first argument to should.

``` ruby
require 'pork/auto'

would{ 1.should('verify one equals to one').eq 1 }
```

In a rare case, constructing the message could be expensive, so we might not
want to build the message if the assertion passed. Then we pass the second
argument as the constructor of the message.

``` ruby
require 'pork/auto'

would{ 1.should(nil, lambda{'verify one equals to one'}).eq 1 }
```

Other than built in assertions such as `eq`, all methods in the questioning
object are available. For example, for arrays we could use `empty?`,
`include?` and `[]`.

``` ruby
describe Array do
  would 'have array methods as verifiers' do
    [ ].should.empty?
    [1].should.include? 1
    [1].should[0]
  end
end
```

The assertions would only fail whenever the result was `false` or `nil`,
otherwise pass.

### Pork::Expect#satisfy

If we want to have custom verifier other than the methods from questioning
object, this is it.

``` ruby
require 'pork/auto'

describe do
  divided_by_2 = lambda{ |n| n % 2 == 0 }

  would do
    2.should.satisfy(&divided_by_2)
  end
end
```

The message argument applies to `should` also applies to `satisfy`.

``` ruby
require 'pork/auto'

describe do
  divided_by_2 = lambda{ |n| n % 2 == 0 }

  would do
    2.should.satisfy('be divided by two', &divided_by_2)
    2.should.satisfy(nil, lambda{'be divided by two'}, &divided_by_2)
  end
end
```

### Pork::Expect#not

An easy way to negate the expectation.

``` ruby
require 'pork/auto'

would{ 1.should.not.eq 2 }
```

### Pork::Expect#eq

To avoid warnings from Ruby, using `eq` instead of `==`. It's fine if you
still prefer using `==` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.eq 1 }
```

### Pork::Expect#lt

To avoid warnings from Ruby, using `lt` instead of `<`. It's fine if you
still prefer using `<` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.lt 2 }
```

### Pork::Expect#gt

To avoid warnings from Ruby, using `gt` instead of `>`. It's fine if you
still prefer using `>` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.gt 0 }
```

### Pork::Expect#lte

To avoid warnings from Ruby, using `lte` instead of `<=`. It's fine if you
still prefer using `<=` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.lte 1 }
```

### Pork::Expect#gte

To avoid warnings from Ruby, using `gte` instead of `>=`. It's fine if you
still prefer using `>=` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.gte 1 }
```

### Pork::Expect#approx

Comparing two floating point numbers is troublesome. `approx` would round on
two numbers so it would make less false positives. There's an optional second
argument which indicates the precision for the fractional part. By default
it's 10. (round on 10)

``` ruby
require 'pork/auto'

would{ 1.23.should.approx 1.225, 2 }
```

### Pork::Expect#raise

Expect for exceptions! There are two ways to call it. Either you could use
lambda to wrap the questioning expression, or you could simply pass a block
as the questioning expression.

``` ruby
require 'pork/auto'

describe 'Pork::Expect#raise' do
  would 'check with a block' do
    e = should.raise(RuntimeError){ raise "nnf" }
    e.should.message.include?("nnf")
  end

  would 'check with a lambda' do
    e = lambda{ raise "nnf" }.should.raise(RuntimeError)
    e.should.message.include?("nnf")
  end
end
```

### Pork::Expect#throw

Expect for something to be thrown. There are two ways to call it. Either
you could use lambda to wrap the questioning expression, or you could
simply pass a block as the questioning expression.

``` ruby
require 'pork/auto'

describe 'Pork::Should#throw' do
  would 'check with a block' do
    e = should.throw(:nnf){ throw :nnf, 0 }
    e.should.eq [:nnf, 0]
  end

  would 'check with a lambda' do
    e = lambda{ throw :nnf, 1 }.should.throw(:nnf)
    e.should.eq [:nnf, 1]
  end
end
```

### Pork::API.describe

So this creates a test suite which should be containing various test cases
(`Pork::API.would`). The argument represents the description of the test
suite, which accepts anything could be converted to a string. The _default_
description is `:default` (which would be converted to `'default: '`)

Each `describe` block would create a new subclass of `Pork::Suite` for
isolating test suites. Each nested `describe` block would be a subclass of
its parent `Pork::Suite`.

``` ruby
require 'pork/auto'

describe do
  would 'be default: for the default description' do
    self.class.desc.should.eq :default
  end
end
```

### Pork::API.would

Essentially runs a test case. It could also be called in the top-level
without being contained in a `describe` block. The argument represents the
description of the test case, which accepts anything could be converted to
a string. The _default_ description is also `:default`.

Each `would` block would be run inside a new instance of the describing
`Pork::Suite` to isolate instance variables.

### Pork::API.before

Each `before` block would be called before each `would` block (test case).
You would probably want to setup stuffs inside `before` blocks.

Each nested `describe` would also run parents' `before` blocks as well.

``` ruby
require 'pork/auto'

describe do
  before do
    @a = 0
  end

  describe do
    before do
      @a.should.eq 0
      @a += 1
    end

    would do
      @a.should.eq 1
    end
  end
end
```

### Pork::API.after

Each `after` block would be called after each `would` block (test case).
You would probably want to cleanup stuffs inside `after` blocks.

Note that each nested `describe` would also run parents' `after` block in a
reverse manner as opposed to `before`.

``` ruby
require 'pork/auto'

describe do
  after do
    @a.should.eq 2
  end

  describe do
    after do
      @a.should.eq 1
      @a += 1
    end

    would do
      @a = 1
      @a.should.eq 1
    end
  end
end
```

### Pork::API.around

Each `around` block would be called before each `would` block (test case),
and whenever it's called, it can take an argument representing the `would`
block (test case). Whenever `call` is called on the test case, it will run.
Essentially it's wrapping around the `would` block.

Note that each nested `describe` would also run parents' `around` block,
following the same order of `before` (in order) and `after` (reverse order).

``` ruby
require 'pork/auto'

describe do
  around do |test|
    @a = 0

    test.call

    @a.should.eq 2
  end

  describe do
    around do |test|
      @a.should.eq 0
      @a += 1

      test.call

      @a.should.eq 1
      @a += 1
    end

    would do
      @a.should.eq 1
    end
  end
end
```

Note that if `test.call` was never called, it'll just act like a `before`
block. All the tests will still run unlike RSpec.

### Pork::API.copy and Pork::API.paste

It could be a bit confusing at first, but just think of `copy` as a way to
store the block with a name (default is `:default`), and whenever we `paste`,
the stored block would be called at the context where we paste.

The name could be anything, strings, symbols, numbers, classes, anything.

The block passed to `copy` could have parameters. The second through the last
arguments passed to `paste` would be passing to the block saved in copy.

``` ruby
require 'pork/auto'

copy :default do |a=0, b=1|
  before do
    @a, @b = a, b
  end

  def f
    @a + @b
  end
end

describe do
  paste :default, 1, 0

  would do
    f.should.eq 1
  end
end
```

### Pork::Suite#expect

It is the core of `Kernel#should`. Think of:

``` ruby
object.should.eq(1)
```

is equivalent to:

``` ruby
expect(object).eq(1)
```

Also:

``` ruby
object.should('message').eq(1)
```

is equivalent to:

``` ruby
expect(object, 'message').eq(1)
```

### Pork::Suite#skip

At times we might want to skip some tests while leave the codes there without
removing them or commenting them out. This is where `skip` would be helpful.

``` ruby
require 'pork/auto'

describe do
  would do
    skip
  end
end
```

### Pork::Suite#ok

Because Pork would complain if a test case does not have any assertions,
sometimes we might want to tell Pork that it's ok because we've already
made some assertions without using Pork's assertions. Then we'll want `ok`.

The reason why complaining about missing assertions is useful is because
sometimes we might expect some assertions would be made in a certain flow.
If the flow is not correctly called, we could miss assertions. So it's good
to explicitly claim that we don't care about assertions rather than letting
them slip through implicitly.

``` ruby
require 'pork/auto'

describe do
  would do
    'verify with mocks, and pork has no idea about that'.to_s
    ok
  end
end
```

### Pork::Suite#flunk

If we're writing program carefully, there are a few cases where a condition
would never meet. We could `raise "IMPOSSIBLE"` or we could simply call
`flunk`.

``` ruby
require 'pork/auto'

describe do
  would do
    should.raise(Pork::Error){ flunk }
  end
end
```

## The Options

### `env PORK_TEST=`

As the code base grows, at some point running the whole test suites could be
very slow and frustrating while doing agile development. In this case, we
might want to run only a subset of the whole test suites. Granted that we
could already divide the tests into files, and only load one file and run
tests inside the file. But if the tests are just slow, we might still want to
run only a specific test case. This is where `env PORK_TEST=` shines.

Suppose you run the tests via:

``` shell
ruby -Ilib test/test_pork.rb
```

Then you could do:

``` shell
env PORK_TEST=test/test_pork.rb:123 ruby -Ilib test/test_pork.rb
```

So that it would only run the test case around test_pork.rb line 123.
If you run the tests via:

``` shell
rake test
```

Then you could do:

``` shell
env PORK_TEST=test/test_pork.rb:123 rake test
```

It's the same thing just that `rake test` might load more tests which would
never run. Note that if you omit the line number, then the whole file would
run.

#### `env PORK_TEST=` with `:groups`

`PORK_TEST` could also take a list of groups. Groups are defined in the tests,
as the second argument to `describe` and `would`. Take this as an example:


``` ruby
describe 'all', :groups => [:all] do
  would 'pass', :groups => [:core, :more] do
    ok
  end

  would 'also pass', :groups => [:more] do
    ok
  end
end
```

Then if specifying `PORK_TEST=all`, or `PORK_TEST=more`, then both tests
would run. If specifying `PORK_TEST=core`, then only the first would run.
We could also specifying multiple groups, separated with commas (,), like
`PORK_TEST=core,more`, then of course both tests would run.

This would be very useful when you want to run a specific test case without
typing the whole file path and finding the line number. Just edit your test
source by adding some temporary group like `:groups => [:only]` and then
run the test command prefixed by `env PORK_TEST=only` then you're done.
You could just remove the group after debugging. This must be much easier to
do then commenting out a bunch of random codes in the tests.

Summary by examples:

* `env PORK_TEST='test/test_pork.rb:123' rake test`
* `env PORK_TEST='test/test_pork.rb' rake test`
* `env PORK_TEST='group0' rake test`
* `env PORK_TEST='group0,group1' rake test`

### `env PORK_SEED=`

By default, before running a test case, Pork would try to generate a
random seed for each test case. This way, we could easily replicate
each test case by setting the same random seed.

However, this could hurt performance and randomness. This is a trade off
before Ruby can restore arbitrary random state. If you don't want this
behaviour, you could set `PORK_SEED=random` to force Pork only set the
seed before running the entire test suite, saving you some performance
and randomness.

Otherwise, you don't have to care about this option. Just copy and
paste the replicating command when one of your test cases failed.

### Pork.protected_exceptions

By default, Pork only rescues exceptions derived from `StandardError`,
this is due to the fact that we don't want to interfere with some system
exception like signal handling and so on so forth. (e.g. `SignalException`,
`LoadError`, `SyntaxError`, etc).

However, some libraries do not raise exceptions derived from `StandardError`.
I would recommend fix them, but as a workaround, you could also tell Pork to
rescue those exceptions so that your test suites won't just stop there.

Let's take webmock as an example, we'll do this to avoid stopping the tests
whenever webmock complains:

``` ruby
Pork.protected_exceptions << WebMock::NetConnectNotAllowedError
```

This would effectively tell Pork to rescue it and treat it as a regular
test error instead of stopping the whole process.

### Pork.execute_mode

By default, `Pork.execute_mode` is set to `:shuffled` which would execute
all tests in a random order. The other options are:

* `:shuffled` (default)
* `:sequential`
* `:parallel`

With `:sequential`, it would execute all tests in a sequential manner.
With `:parallel`, it would run tests with 8 threads concurrently, and of
course, the orders are all random as well. You'll need to make sure your
tests are thread safe or random tests would fail with this mode.

Pass the symbol to it to use the mode:

``` ruby
Pork.execute_mode :parallel
```

On the other hand, you could also set `ENV['PORK_MODE']` for picking an
execution mode. This would be convenient if you just want to switch to a
particular mode temporary via command line. For example:

``` shell
env PORK_MODE=parallel rake test
```

Or:

``` shell
env PORK_MODE=parallel ruby -Ilib test/test_pork.rb
```

### Pork.report_mode

By default, `Pork.report_mode` is set to `:dot` which would print a dot
for each test case. This is the same as test/unit bundled in Ruby. We
provide another option: `:description` which would print the description
for each test case. This might be useful if you are not running a bunch
of test cases. All the options are:

* `:dot` (default)
* `:description`
* `:progressbar` (needs [ruby-progressbar][])

Pass the symbol to it to use the mode:

``` ruby
Pork.report_mode :description
```

Or if you want to use a progressbar:

``` ruby
Pork.report_mode :progressbar
# Show your love for rainbows when you're feeling lucky! Highly recommended!
Pork.Rainbows! if rand(50) == 0
```

On the other hand, you could also set `ENV['PORK_REPORT']` for picking an
reporting mode. This would be convenient if you just want to switch to a
particular mode temporary via command line. For example:

``` shell
env PORK_REPORT=progressbar rake test
```

Or:

``` shell
env PORK_REPORT=progressbar ruby -Ilib test/test_pork.rb
```

Caveat: You might see interleaving description output if you're running
`Pork.report_mode :description` with `Pork.execute_mode :shuffled` because...
it's shuffled. You might want to run in `Pork.execute_mode :sequential`
when using description report if you don't want to see interleaving
descriptions.

### Pork.inspect_failure_mode

By default, `Pork.inspect_failure_mode` is set to `:auto`, which would
display failures accordingly. For example, if the message is short, it would
simply show the message. But if the message is long, it would try to insert
a newline between actual result and expected result, since it would be much
easier for human to distinguish the difference this way. If the message is
really long, it would even use `diff` to show the difference.

This is because if the actual string is long, it would be quite painful to
find the actual difference for human without assistance.

Additionally, if both the actually object and expected object are hashes,
and if the actually hash is fairly large, it would also try to differentiate
the two and give you a more readable result like:

```
Pork::Failure: Expect
        Hash with key path: "categories:0:chats:0:mentor:username"
"Expect Name".==("Actual Name") to return true
```

For this:

``` ruby
mentor = {"Some" => "Random", "Data" => "Here", "This's" => "Large"}
expect("categories" => [{"chats" => [{"mentor" =>
         mentor.merge("username" => "Actual Name")}]}]).eq \
       "categories" => [{"chats" => [{"mentor" =>
         mentor.merge("username" => "Expect Name")}]}]
```

This should much improve the time to figure out why it's failing.

However, this might not really be desired at times. So we should be able to
switch between each mode. For now, we have the following modes:

* `:auto` (default)
* `:inline`
* `:newline`
* `:diff`

If we want to force to a specific mode, here's how we would do:

``` ruby
Pork.inspect_failure_mode :newline
```

Then it would always use the mode we specified.

### Pork.autorun

Calling this would register an `at_exit` hook to run tests at exit.
This also accepts an argument to turn on and off autorun. Calling this
multiple times is ok. (It's not thread safe though, don't call this twice
from different threads at the same time. If you really want to do this,
let's add a mutex for this)

It would also exit with 0 if no error occurs or N for N errors and failures.

``` ruby
Pork.autorun        # enable
Pork.autorun(false) # disable
Pork.autorun(true)  # enable
```

`require 'pork/auto'` would call `Pork.autorun`

### Pork.show_source

If you have [method_source][] installed, you could call this and have Pork
print the source to the failing lines. Here's an example of what Pork would
print with `Pork.show_source`:

```
  Replicate this test with:
env PORK_TEST='test/test_pork.rb:12' PORK_MODE=shuffled PORK_SEED=345 /usr/bin/ruby -S test/test_pork.rb
  test/test_pork.rb:13:in `block in <main>'
     would 'print the source' do
  =>   flunk
     end
would print the source
Pork::Error: Flunked
```

### Pork.Rainbows!

Have you seen Rainbows!?

![Screenshot](https://github.com/godfat/pork/raw/master/screenshot.png)

## CONTRIBUTORS:

* Chun-Yi Liu (@trantorliu)
* Lin Jen-Shin (@godfat)
* Josh Kalderimis (@joshk)
* Yang-Hsing Lin (@mz026)

## LICENSE:

Apache License 2.0 (Apache-2.0)

Copyright (c) 2014-2022, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
