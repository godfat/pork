
require 'pork/auto'
require 'pork/parallel'

require 'muack'

describe Pork::Parallel do
  after do
    Muack.reset
  end

  would '#parallel' do
    Muack::API.stub(Pork::Executor.all_tests).keys.peek_return do |names|
      names.reject do |n|
        n =~ /^Pork::(Isolate|Shuffle|Parallel) /
      end
    end
    stat = Pork::Executor.parallel(8, @__pork__stat__)
    expect(stat.passed?, stat.inspect).eq true
  end
end
