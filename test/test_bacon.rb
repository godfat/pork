
require 'pork'

# Hooray for meta-testing.
module MetaTests
  def succeed block
    block.should.not.raise Pork::Error
  end

  def fail block
    block.should.raise Pork::Error
  end

  def equal_string x
    lambda{ |s| x == s.to_s }
  end
end

Pork::API.describe Pork do
  include MetaTests

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

  would "have should.flunk" do
    fail lambda { should.flunk }
    fail lambda { should.flunk "yikes" }
  end
end

# describe "before/after" do
#   before do
#     @a = 1
#     @b = 2
#     @c = nil
#   end

#   before do
#     @a = 2
#   end

#   after do
#     @a.should.equal 2
#     @a = 3
#   end

#   after do
#     @a.should.equal 3
#   end

#   it "should run in the right order" do
#     @a.should.equal 2
#     @b.should.equal 2
#   end

#   describe "when nested" do
#     before do
#       @c = 5
#     end

#     it "should run from higher level" do
#       @a.should.equal 2
#       @b.should.equal 2
#     end

#     it "should run at the nested level" do
#       @c.should.equal 5
#     end

#     before do
#       @a = 5
#     end

#     it "should run in the right order" do
#       @a.should.equal 5
#       @a = 2
#     end
#   end

#   it "should not run from lower level" do
#     @c.should.be.nil
#   end

#   describe "when nested at a sibling level" do
#     it "should not run from sibling level" do
#       @c.should.be.nil
#     end
#   end
# end

# shared "a shared context" do
#   it "gets called where it is included" do
#     true.should.be.true
#   end
# end

# shared "another shared context" do
#   it "can access data" do
#     @magic.should.be.equal 42
#   end
# end

# describe "shared/behaves_like" do
#   behaves_like "a shared context"

#   ctx = self
#   it "raises NameError when the context is not found" do
#     lambda {
#       ctx.behaves_like "whoops"
#     }.should.raise NameError
#   end

#   behaves_like "a shared context"

#   before {
#     @magic = 42
#   }
#   behaves_like "another shared context"
# end

# describe "Methods" do
#   def the_meaning_of_life
#     42
#   end

#   def the_towels
#     yield "DON'T PANIC"
#   end

#   it "should be accessible in a test" do
#     the_meaning_of_life.should == 42
#   end

#   describe "when in a sibling context" do
#     it "should be accessible in a test" do
#       the_meaning_of_life.should == 42
#     end

#     it "should pass the block" do
#       the_towels do |label|
#         label.should == "DON'T PANIC"
#       end.should == true
#     end
#   end
# end

# describe 'describe arguments' do

#   def check(ctx,name)
#     ctx.should.be.an.instance_of Bacon::Context
#     ctx.instance_variable_get('@name').should == name
#   end

#   it 'should work with string' do
#     check(describe('string') {},'string')
#   end

#   it 'should work with symbols' do
#     check(describe(:behaviour) {},'behaviour')
#   end

#   it 'should work with modules' do
#     check(describe(Bacon) {},'Bacon')
#   end

#   it 'should work with namespaced modules' do
#     check(describe(Bacon::Context) {},'Bacon::Context')
#   end

#   it 'should work with multiple arguments' do
#     check(describe(Bacon::Context, :empty) {},'Bacon::Context empty')
#   end

# end

Pork.report
