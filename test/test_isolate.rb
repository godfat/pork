
require 'pork/auto'
require 'pork/isolate'

describe Pork::Isolate do
  would '#isolate' do
    50.times do
      name = Pork::Executor.all_tests.keys.sample
      next ok if name.start_with?('Pork::Isolate #isolate #')
      stat = Pork::Executor.isolate(name, @__pork__stat__)
      expect(stat.passed?, stat.inspect).eq true
    end
  end
end
