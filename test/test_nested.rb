
require 'pork/test'

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
    flunk
  end
end

would 'also work on top-level' do
  true.should.eq true
end

describe 'should(message)' do
  would 'show message' do
    should.raise(Pork::Failure){ should('nnf').satisfy('qoo'){ false } }.
      message.should.eq "Expect qoo\nnnf"
  end

  would 'show lazy message' do
    should.raise(Pork::Failure) do
      should(nil, lambda{'nnf'}).satisfy(nil, lambda{'qoo'}){ false }
    end.message.should.eq "Expect qoo\nnnf"
  end
end

describe Pork::Context do
  would(desc = rand) do
    expect(pork_description).eq desc
  end
end
