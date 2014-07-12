
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
