
require 'pork/auto'
require 'pork/isolate'

describe Pork::Isolate do
  would '#isolate' do
    skip
    20.times do
      name = Pork::Executor.all_tests.keys.sample
      next ok if name.start_with?('Pork::Isolate #isolate #')
      executor = Pork::Executor.isolate(name).execute
      expect(executor.passed?, executor.stat.inspect).eq true
    end
  end
end
