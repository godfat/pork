
require 'pork'
require 'pork/isolate'

module Pork
  module Shuffle
    def shuffle stat=Stat.new
      all_tests.values.flatten(1).shuffle.each do |path|
        isolate(path, stat)
      end
      stat
    end
  end

  Executor.extend(Shuffle)
end
