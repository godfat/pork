
require 'pork/isolate'

module Pork
  module Shuffled
    def shuffled stat=Stat.new, paths=all_paths
      paths.shuffle.inject(stat, &method(:isolate))
    end
  end

  Executor.extend(Shuffled)
end
