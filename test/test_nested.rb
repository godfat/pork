
require 'pork'

module M
  def m
    object_id
  end
end

Pork::API.describe 'A' do
  include M

  def f
    object_id
  end

  would 'f' do
    f.should.eq m
    f.should.kind_of? Fixnum
    lambda{ f.should.eq '' }.should.raise RuntimeError
  end

  describe 'B' do
    would 'have the same context' do
      f.should == m
      m.should.not.kind_of? String
      lambda{ throw :halt }.should.throw :halt
      lambda{ lambda{ throw :halt }.should.not.throw :halt }.
        should.raise RuntimeError
    end
  end
end

Pork.report
