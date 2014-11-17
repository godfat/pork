# Pork [![Build Status](https://secure.travis-ci.org/godfat/pork.png?branch=master)](http://travis-ci.org/godfat/pork) [![Coverage Status](https://coveralls.io/repos/godfat/pork/badge.png)](https://coveralls.io/r/godfat/pork)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/pork)
* [rubygems](https://rubygems.org/gems/pork)
* [rdoc](http://rdoc.info/github/godfat/pork)

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
  # If we want, we could do this instead: `Pork::Executor.include(Module.new)`
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

* Tested with MRI (official CRuby), Rubinius and JRuby.

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

### Pork::Should#satisfy

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

### Pork::Should#not

An easy way to negate the expectation.

``` ruby
require 'pork/auto'

would{ 1.should.not.eq 2 }
```

### Pork::Should#eq

To avoid warnings from Ruby, using `eq` instead of `==`. It's fine if you
still prefer using `==` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.eq 1 }
```

### Pork::Should#lt

To avoid warnings from Ruby, using `lt` instead of `<`. It's fine if you
still prefer using `<` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.lt 2 }
```

### Pork::Should#gt

To avoid warnings from Ruby, using `gt` instead of `>`. It's fine if you
still prefer using `>` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.gt 0 }
```

### Pork::Should#lte

To avoid warnings from Ruby, using `lte` instead of `<=`. It's fine if you
still prefer using `<=` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.lte 1 }
```

### Pork::Should#gte

To avoid warnings from Ruby, using `gte` instead of `>=`. It's fine if you
still prefer using `>=` if you don't care about warnings.

``` ruby
require 'pork/auto'

would{ 1.should.gte 1 }
```

### Pork::Should#raise

Expect for exceptions! There are two ways to call it. Either you could use
lambda to wrap the questioning expression, or you could simply pass a block
as the questioning expression.

``` ruby
require 'pork/auto'

describe 'Pork::Should#raise' do
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

### Pork::Should#throw

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

Each `describe` block would create a new subclass of `Pork::Executor` for
isolating test suites. Each nested `describe` block would be a subclass of
its parent `Pork::Executor`.

``` ruby
require 'pork/auto'

describe do
  would 'be default: for the default description' do
    self.class.desc.should.eq 'default:'
  end
end
```

### Pork::API.would

Essentially runs a test case. It could also be called in the top-level
without being contained in a `describe` block. The argument represents the
description of the test case, which accepts anything could be converted to
a string. The _default_ description is also `:default`.

Each `would` block would be run inside a new instance of the describing
`Pork::Executor` to isolate instance variables.

``` ruby
require 'pork/auto'

would do
  @__pork__desc__.should.eq :default
end
```

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

Each nested `describe` would also run parents' `after` block as well.

``` ruby
require 'pork/auto'

describe do
  after do
    @a.should.eq 1
    @a += 1
  end

  describe do
    after do
      @a.should.eq 2
    end

    would do
      @a = 1
      @a.should.eq 1
    end
  end
end
```

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

### Pork::Executor#skip

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

### Pork::Executor#ok

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

### Pork::Executor#flunk

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

### Pork.report

Report the summary from the tests. Usually you would want to call this at
program exit, therefore most of the time you would want `Pork.report_at_exit`
instead, unless you want to report the summary without exiting.

Note that you would probably want to run `Pork.stats.start` at the beginning
of your tests as well if you want to handle `Pork.report` manually.

### Pork.report_at_exit

Basically simply call `Pork.stats.start` and setup `Pork.report` at exit,
and exit with 0 if no error occurs or N for N errors and failures.

If you also plan to pollute the top-level namespace so that you could simply
call `describe` on top-level instead of calling it `Pork::API.describe`,
you would probably want to simply `require 'pork/auto'` which is essentially:

``` ruby
require 'pork'
extend Pork::API
Pork.report_at_exit
```

### Pork.inspect_failure_mode

By default, `Pork.inspect_failure_mode` is set to `:auto`, which would
display failures accordingly. For example, if the message is short, it would
simply show the message. But if the message is long, it would try to insert
a newline between actual result and expected result, since it would be much
easier for human to distinguish the difference this way. If the message is
really long, it would even use `diff` to show the difference.

This is because if the actual string is long, it would be quite painful to
find the actual difference for human without assistance.

However, this might not really be desired at times. So we should be able to
switch between each mode. For now, we have the following modes:

* :auto (default)
* :inline
* :newline
* :diff

If we want to force to a specific mode, here's how we would do:

``` ruby
Pork.inspect_failure_mode :newline
```

Then it would always use the mode we specified.

## CONTRIBUTORS:

* Lin Jen-Shin (@godfat)
* Josh Kalderimis (@joshk)

## LICENSE:

Apache License 2.0

Copyright (c) 2014, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
