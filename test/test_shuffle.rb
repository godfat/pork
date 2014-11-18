
require 'pork/test'
require 'pork/shuffle'

describe Pork::Shuffle do
  paste

  would '#shuffle' do
    stat = Pork::Executor.shuffle(@__pork__stat__)
    expect(stat.passed?, stat.inspect).eq true
  end
end
