# Pork [![Build Status](https://secure.travis-ci.org/godfat/pork.png?branch=master)](http://travis-ci.org/godfat/pork)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/pork)
* [rubygems](https://rubygems.org/gems/pork)
* [rdoc](http://rdoc.info/github/godfat/pork)

## DESCRIPTION:

Pork -- Simple and clean and modular testing library.

[Bacon][] reimplemented around 250 lines of code.

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
    self.class.desc.should.eq 'default: '
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
  desc.should.eq :default
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

### Pork::Executor#flunk

### Pork::Should#satisfy

### Pork::Should#not

### Pork::Should#eq

### Pork::Should#lt

### Pork::Should#gt

### Pork::Should#lte

### Pork::Should#gte

### Pork::Should#raise

### Pork::Should#throw

### Pork.report

### Pork.report_at_exit

## CONTRIBUTORS:

* Lin Jen-Shin (@godfat)

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
