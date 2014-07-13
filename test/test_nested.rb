
require 'pork/auto'

describe 'A' do
  include Module.new{
    def m
      object_id
    end
  }

  def f
    object_id
  end

  would 'f' do
    f.should.eq m
    f.should.kind_of? Fixnum
    lambda{ f.should.eq '' }.should.raise Pork::Failure
  end

  copy do
    def t
      true
    end

    would do
      t.should.eq true
    end
  end

  paste

  describe 'B' do
    would 'have the same context' do
      f.should.eq m
      m.should.not.kind_of? String
      lambda{ throw :halt }.should.throw :halt
      lambda{ lambda{ throw :halt }.should.not.throw :halt }.
        should.raise Pork::Failure
    end

    paste

    would do
      t.should.eq true
    end

    describe 'C' do
      paste
    end
  end

  would 'skip' do
    skip
    should.flunk
  end
end

would 'also work on top-level' do
  true.should.eq true
end

describe 'Pork.inspect_failure' do
  would 'hash' do
    Pork.inspect_failure_auto(
      {:b => 1, :a => 0}, :==, [{:a => 1, :b => 0}], false).
      should.eq '{:a=>0, :b=>1}.==({:a=>1, :b=>0}) to return true'
  end

  would 'newline' do
    obj, arg = 'a'*80, 'b'*80
    Pork.inspect_failure_auto(obj, :==, [arg], true).
      should.eq "\n#{obj.inspect}.==(\n#{arg.inspect}) to return false"
  end

  would 'diff' do
    s = File.read(__FILE__)
    n = s.count("\n")
    Pork.inspect_failure_auto(s, :==, ["#{s}b\n"], true).
      should.eq "String#==(\n#{n}a#{n+1}\n> b\n) to return false"
  end
end
