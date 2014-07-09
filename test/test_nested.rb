
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

  describe 'B' do
    would 'have the same context' do
      f.should == m
      m.should.not.kind_of? String
      lambda{ throw :halt }.should.throw :halt
      lambda{ lambda{ throw :halt }.should.not.throw :halt }.
        should.raise Pork::Failure
    end
  end

  would 'skip' do
    skip
    true.should.eq false
  end
end

Pork.report
