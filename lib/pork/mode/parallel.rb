
require 'pork'
require 'pork/isolate'

module Pork
  module Parallel
    def parallel cores=8, stat=Stat.new
      all_tests.keys.shuffle.each_slice(cores).map do |names|
        Thread.new{ names.each{ |n| isolate(n, stat) } }
      end.each(&:join)
      stat
    end
  end

  Executor.extend(Parallel)
end
