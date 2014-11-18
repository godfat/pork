
require 'pork/auto'
require 'pork/shuffle'

require 'muack'

describe Pork::Shuffle do
  after do
    Muack.reset
  end

  would '#shuffle' do
    Muack::API.stub(Pork::Executor.all_tests).keys.peek_return do |names|
      names.reject do |n|
        n =~ /^Pork::(Isolate|Shuffle|Parallel) /
      end
    end
    stat = Pork::Executor.shuffle(@__pork__stat__)
    expect(stat.passed?, stat.inspect).eq true
  end
end
