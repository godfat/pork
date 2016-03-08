
module Pork
  module Sequential
    def sequential stat=Stat.new, paths=all_paths
      stat.prepare(paths)
      paths.inject(stat, &method(:isolate))
    end
  end

  Executor.extend(Sequential)
end
