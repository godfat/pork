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
