
require 'pork/mode/shuffled'

module Pork
  module Parallel
    extend self

    def cores
      8
    end

    def execute isolator, stat=Stat.new, paths=isolator.all_paths
      stat.prepare(paths)
      paths.shuffle.each_slice(cores).map do |paths_slice|
        Thread.new do
          Shuffled.execute(
            isolator,
            Stat.new(stat.reporter, stat.protected_exceptions),
            paths_slice)
        end
      end.map(&:value).inject(stat, &:merge)
    end
  end
end
