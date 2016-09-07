
require 'pork/mode/shuffled'

module Pork
  class Parallel
    def cores
      8
    end

    def execute isolator, stat=Stat.new, paths=isolator.all_paths
      executor = Shuffled.new
      stat.prepare(paths)
      paths.shuffle.each_slice(cores).map do |paths_slice|
        Thread.new do
          executor.execute(
            isolator,
            Stat.new(stat.reporter, stat.protected_exceptions),
            paths_slice)
        end
      end.map(&:value).inject(stat, &:merge)
    end
  end
end
