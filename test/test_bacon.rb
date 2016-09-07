
require 'pork/test'

describe Pork do
  # Hooray for meta-testing.
  include Module.new{
    def succeed block
      block.should.not.raise Pork::Error
    end

    def fail block
      block.should.raise Pork::Error
    end

    def equal_string x
      lambda{ |s| x == s.to_s }
    end
  }

  would "have should.satisfy" do
    succeed lambda { should.satisfy { 1 == 1 } }
    succeed lambda { should.satisfy { 1 } }

    fail lambda { should.satisfy { 1 != 1 } }
    fail lambda { should.satisfy { false } }

    fail lambda { 1.should.satisfy { |n| n % 2 == 0 } }
    succeed lambda { 2.should.satisfy { |n| n % 2 == 0 } }
  end

  would "have should.==" do
    succeed lambda { "string1".should == "string1" }
    fail    lambda { "string1".should == "string2" }

    succeed lambda { [1,2,3].should == [1,2,3] }
    fail lambda { [1,2,3].should == [1,2,4] }
  end

  would "have should.eq" do
    succeed lambda { "string1".should == "string1" }
    fail lambda { "string1".should == "string2" }
    fail lambda { "1".should == 1 }

    succeed lambda { "string1".should.eq "string1" }
    fail lambda { "string1".should.eq "string2" }
    fail lambda { "1".should.eq 1 }
  end

  would "have should.raise" do
    succeed lambda { lambda { raise "Error" }.should.raise }
    succeed lambda { lambda { raise "Error" }.should.raise RuntimeError }
    fail lambda { lambda { raise "Error" }.should.not.raise }
    fail lambda { lambda { raise "Error" }.should.not.raise RuntimeError }

    fail lambda { lambda { 1 + 1 }.should.raise }
    lambda {
      lambda { raise "Error" }.should.raise(Interrupt)
    }.should.raise
  end

  would "should.raise with a block" do
    succeed lambda { should.raise { raise "Error" } }
    succeed lambda { should.raise(RuntimeError) { raise "Error" } }
    fail lambda { should.not.raise { raise "Error" } }
    fail lambda { should.not.raise(RuntimeError) { raise "Error" } }

    fail lambda { should.raise { 1 + 1 } }
    lambda {
      should.raise(Interrupt) { raise "Error" }
    }.should.raise
  end

  would "have a should.raise should return the exception" do
    ex = lambda { raise "foo!" }.should.raise
    ex.should.kind_of? RuntimeError
    ex.message.should =~ /foo/
  end

  would "have should.nil?" do
    succeed lambda { nil.should.nil? }
    fail lambda { nil.should.not.nil? }
    fail lambda { "foo".should.nil? }
    succeed lambda { "foo".should.not.nil? }
  end

  would "have should.include?" do
    succeed lambda { [1,2,3].should.include? 2 }
    fail lambda { [1,2,3].should.include? 4 }

    succeed lambda { {1=>2, 3=>4}.should.include? 1 }
    fail lambda { {1=>2, 3=>4}.should.include? 2 }
  end

  would "have should.kind_of?" do
    succeed lambda { Array.should.kind_of? Module }
    succeed lambda { "string".should.kind_of? Object }
    succeed lambda { 1.should.kind_of? Comparable }

    succeed lambda { Array.should.kind_of? Module }
    fail lambda { "string".should.kind_of? Class }
  end

  would "have should.match" do
    succeed lambda { "string".should.match(/strin./) }
    succeed lambda { "string".should =~ /strin./ }

    fail lambda { "string".should.match(/slin./) }
    fail lambda { "string".should =~ /slin./ }
  end

  would "have should.not.raise" do
    succeed lambda { lambda { 1 + 1 }.should.not.raise }
    succeed lambda { lambda { 1 + 1 }.should.not.raise(Interrupt) }

    succeed lambda {
      lambda {
        lambda {
          raise ZeroDivisionError.new("ArgumentError")
        }.should.not.raise(RuntimeError)
      }.should.raise(ZeroDivisionError)
    }

    fail lambda { lambda { raise "Error" }.should.not.raise }
  end

  would "have should.throw" do
    succeed lambda { lambda { throw :foo }.should.throw(:foo) }
    fail lambda { lambda {       :foo }.should.throw(:foo) }

    should.throw(:foo) { throw :foo }
  end

  would "have should.not.satisfy" do
    succeed lambda { should.not.satisfy { 1 == 2 } }
    fail lambda { should.not.satisfy { 1 == 1 } }
  end

  would "have should.not.equal" do
    succeed lambda { "string1".should.not == "string2" }
    fail lambda { "string1".should.not == "string1" }
  end

  would "have should.not.match" do
    succeed lambda { "string".should.not.match(/sling/) }
    fail lambda { "string".should.not.match(/string/) }
    fail lambda { "string".should.not.match("strin") }

    succeed lambda { "string".should.not =~ /sling/ }
    fail lambda { "string".should.not =~ /string/ }
  end

  would "have should.respond_to" do
    succeed lambda { "foo".should.respond_to? :to_s }
    fail lambda { 5.should.respond_to? :to_str }
    fail lambda { :foo.should.respond_to? :nx }
  end

  would "support multiple negation" do
    succeed lambda { 1.should.eq 1 }
    fail lambda { 1.should.not.eq 1 }
    succeed lambda { 1.should.not.not.eq 1 }
    fail lambda { 1.should.not.not.not.eq 1 }

    fail lambda { 1.should.eq 2 }
    succeed lambda { 1.should.not.eq 2 }
    fail lambda { 1.should.not.not.eq 2 }
    succeed lambda { 1.should.not.not.not.eq 2 }
  end

  would "have should.<predicate>" do
    succeed lambda { [].should.empty? }
    succeed lambda { [1,2,3].should.not.empty? }

    fail lambda { [].should.not.empty? }
    fail lambda { [1,2,3].should.empty? }

    succeed lambda { {1=>2, 3=>4}.should.has_key? 1 }
    succeed lambda { {1=>2, 3=>4}.should.not.has_key? 2 }

    lambda { nil.should.bla }.should.raise(NoMethodError)
    lambda { nil.should.not.bla }.should.raise(NoMethodError)
  end

  would "have should <operator> (>, >=, <, <=, ===)" do
    succeed lambda { 2.should > 1 }
    fail lambda { 1.should > 2 }

    succeed lambda { 1.should < 2 }
    fail lambda { 2.should < 1 }

    succeed lambda { 2.should >= 1 }
    succeed lambda { 2.should >= 2 }
    fail lambda { 2.should >= 2.1 }

    fail lambda { 2.should <= 1 }
    succeed lambda { 2.should <= 2 }
    succeed lambda { 2.should <= 2.1 }

    succeed lambda { Array.should === [1,2,3] }
    fail lambda { Integer.should === [1,2,3] }

    succeed lambda { /foo/.should === "foobar" }
    fail lambda { "foobar".should === /foo/ }
  end

  would "allow for custom shoulds" do
    f = equal_string("2")
    succeed lambda { (1+1).should(&f) }
    fail lambda { (1+2).should(&f) }

    succeed lambda { (1+1).should(&f) }
    fail lambda { (1+2).should(&f) }

    fail lambda { (1+1).should.not(&f) }
    succeed lambda { (1+2).should.not(&f) }
    fail lambda { (1+2).should.not.not(&f) }

    fail lambda { (1+1).should.not(&f) }
    succeed lambda { (1+2).should.not(&f) }
  end

  would "have flunk" do
    fail lambda { flunk }
    fail lambda { flunk "yikes" }
  end
end

describe "before/after" do
  before do
    @a = 1
    @b = 2
    @c = nil
  end

  before do
    @a = 2
  end

  # after should run in reverse order
  after do
    @a.should.eq 3
  end

  after do
    @a.should.eq 2
    @a = 3
  end

  would "run in the right order" do
    @a.should.eq 2
    @b.should.eq 2
  end

  describe "when nested" do
    before do
      @c = 5
    end

    would "run from higher level" do
      @a.should.eq 2
      @b.should.eq 2
    end

    would "run at the nested level" do
      @c.should.eq 5
    end

    before do
      @a = 5
    end

    would "run in the right order" do
      @a.should.eq 5
      @a = 2
    end
  end

  would "not run from lower level" do
    @c.should.nil?
  end

  describe "when nested at a sibling level" do
    would "not run from sibling level" do
      @c.should.nil?
    end
  end
end

copy "a shared context" do
  would "get called where it is included" do
    true.should.eq true
  end
end

copy "another shared context" do
  would "access data" do
    @magic.should.eq 42
  end
end

describe "shared/behaves_like" do
  paste "a shared context"

  ctx = self
  would "raise NameError when the context is not found" do
    lambda {
      ctx.paste "whoops"
    }.should.raise LocalJumpError
  end

  paste "a shared context"

  before {
    @magic = 42
  }
  paste "another shared context"
end

describe "Methods" do
  def the_meaning_of_life
    42
  end

  def the_towels
    yield "DON'T PANIC"
  end

  would "be accessible in a test" do
    the_meaning_of_life.should.eq 42
  end

  describe "when in a sibling context" do
    would "should be accessible in a test" do
      the_meaning_of_life.should.eq 42
    end

    would "should pass the block" do
      the_towels do |label|
        label.should.eq "DON'T PANIC"
      end.should.eq true
    end
  end
end

describe 'describe arguments' do
  check = lambda do |ctx, desc, name=nil|
    ctx.should.lt Pork::Suite
    ctx.description_for(name).should.eq "#{desc}: #{name}"
  end

  would 'work with string' do
    str = 'string'
    Pork::API.describe(str) do
      check[self, str]
      would 'a' do check[self.class, str, 'a'] end
    end
  end

  would 'work with symbols' do
    str = 'behaviour'
    Pork::API.describe(:behaviour) do
      check[self, str]
      would 'b' do check[self.class, str, 'b'] end
    end
  end

  would 'work with modules' do
    str = 'Pork'
    Pork::API.describe(Pork) do
      check[self, str]
      would 'c' do check[self.class, str, 'c'] end
    end
  end

  would 'work with namespaced modules' do
    str = 'Pork::Suite'
    Pork::API.describe(Pork::Suite) do
      check[self, str]
      would 'd' do check[self.class, str, 'd'] end
    end
  end
end
