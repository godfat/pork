
require 'pork/auto'
require 'pork/isolate'

describe Pork::Isolate do
  would '#isolate' do
    Pork::Executor.all_tests.each do |name, paths|
      next ok if name.start_with?('Pork::Isolate: would #isolate')
      paths.each do |p|
        stat = Pork::Executor.isolate(p, pork_stat)
        expect(stat.passed?, stat.inspect).eq true
      end
    end
  end
end
