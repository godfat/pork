
require 'pork'
require 'pork/isolate'

module Pork
  module Parallel
    def parallel cores=8, stat=Stat.new
      all_tests.keys.shuffle.each_slice(cores).map do |names|
        Thread.new do
          s = Stat.new
          names.each{ |n| isolate(n, s) }
          s
        end
      end.map(&:value).inject(stat, &:merge)
    end
  end

  Executor.extend(Parallel)
end
