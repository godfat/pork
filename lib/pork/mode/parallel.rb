
require 'pork/mode/shuffled'

module Pork
  class Parallel < Struct.new(:isolator)
    def cores
      8
    end

    def execute stat=Stat.new, paths=isolator.all_paths
      executor = Shuffled.new(isolator)
      stat.prepare(paths)
      paths.shuffle.each_slice(cores).map do |paths_slice|
        Thread.new do
          executor.execute(
            Stat.new(stat.reporter, stat.protected_exceptions),
            paths_slice)
        end
      end.map(&:value).inject(stat, &:merge)
    end
  end
end
