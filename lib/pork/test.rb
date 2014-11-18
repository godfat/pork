
require 'pork/auto'
require 'muack'

copy do
  before do
    Muack::API.stub(Pork::Executor.all_tests).keys.peek_return do |names|
      names.reject do |n|
        n =~ /^Pork::(Isolate|Shuffle|Parallel) /
      end
    end
  end

  after do
    Muack.reset
  end
end
