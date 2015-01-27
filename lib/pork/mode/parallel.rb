
require 'pork'
require 'pork/isolate'

module Pork
  module Parallel
    def parallel cores=8, stat=Stat.new
      all_tests.values.flatten(1).shuffle.each_slice(cores).map do |paths|
        Thread.new do
          s = Stat.new
          paths.each{ |p| isolate(p, s) }
          s
        end
      end.map(&:value).inject(stat, &:merge)
    end
  end

  Executor.extend(Parallel)
end
