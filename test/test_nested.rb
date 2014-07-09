
require 'pork'

Pork::API.describe 'A' do
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
    would do
      true.should.eq true
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
  end

  would 'skip' do
    skip
    should.flunk
  end
end

Pork.report
