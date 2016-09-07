
require 'pork/executor'

module Pork
  class Shuffled < Executor
    def execute stat=Stat.new, paths=isolator.all_paths
      stat.prepare(paths)
      paths.shuffle.inject(stat, &isolator.method(:isolate))
    end
  end
end
