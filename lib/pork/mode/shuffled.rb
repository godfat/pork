
module Pork
  module Shuffled
    extend self

    def execute isolator, stat=Stat.new, paths=isolator.all_paths
      stat.prepare(paths)
      paths.shuffle.inject(stat, &isolator.method(:isolate))
    end
  end
end
