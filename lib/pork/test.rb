
require 'pork/auto'
require 'muack'

copy do
  before do
    Muack::API.stub(Pork::Executor).all_tests.peek_return do |tests|
      tests.reject do |name, _|
        name =~ /^Pork::(Isolate|Shuffle|Parallel): /
      end
    end
  end

  after do
    Muack.reset
  end
end
