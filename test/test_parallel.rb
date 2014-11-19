
require 'pork/test'
require 'pork/parallel'

describe Pork::Parallel do
  paste

  would '#parallel' do
    stat = Pork::Executor.parallel(8, pork_stat)
    expect(stat.passed?, stat.inspect).eq true
  end
end
