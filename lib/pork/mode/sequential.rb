
require 'pork/executor'

module Pork
  class Sequential < Executor
    def execute stat=Stat.new, paths=isolator.all_paths
      stat.prepare(paths)
      paths.inject(stat, &isolator.method(:isolate))
    end
  end
end
