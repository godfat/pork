
require 'pork/test'
require 'pork/shuffle'

describe Pork::Shuffle do
  paste

  would '#shuffle' do
    stat = Pork::Executor.shuffle(pork_stat)
    expect(stat.passed?, stat.inspect).eq true
  end
end
