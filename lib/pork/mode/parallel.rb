
require 'pork/mode/shuffled'

module Pork
  module Parallel
    def cores
      8
    end

    def parallel stat=Stat.new, paths=all_tests.values.flatten(1)
      paths.shuffle.each_slice(cores).map do |paths_slice|
        Thread.new do
          s = Stat.new
          paths_slice.each{ |p| execute(:shuffled, s, [p]) }
          s
        end
      end.map(&:value).inject(stat, &:merge)
    end
  end

  Executor.extend(Parallel)
end
