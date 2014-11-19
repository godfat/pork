
require 'pork/auto'
require 'pork/isolate'

describe Pork::Isolate do
  would '#isolate' do
    Pork::Executor.all_tests.each_key do |name|
      next ok if name.start_with?('Pork::Isolate #isolate #')
      stat = Pork::Executor.isolate(name, pork_stat)
      expect(stat.passed?, stat.inspect).eq true
    end
  end
end
