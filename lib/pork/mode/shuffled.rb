
module Pork
  module Shuffled
    def shuffled stat=Stat.new, paths=all_paths
      stat.prepare(paths)
      paths.shuffle.inject(stat, &method(:isolate))
    end
  end

  Executor.extend(Shuffled)
end
