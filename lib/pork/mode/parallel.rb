
require 'pork/mode/shuffled'

module Pork
  module Parallel
    def cores
      8
    end

    def parallel stat=Stat.new, paths=all_paths
      paths.shuffle.each_slice(cores).map do |paths_slice|
        Thread.new do
          execute(:shuffled, Stat.new(stat.io), paths_slice)
        end
      end.map(&:value).inject(stat, &:merge)
    end
  end

  Executor.extend(Parallel)
end
