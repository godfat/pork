
require 'pork'
require 'pork/isolate'

module Pork
  module Shuffle
    def shuffle stat=Stat.new, paths=all_tests.values.flatten(1)
      paths.shuffle.each do |p|
        isolate(p, stat)
      end
      stat
    end
  end

  Executor.extend(Shuffle)
end
