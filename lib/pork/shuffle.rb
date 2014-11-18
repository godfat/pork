
require 'pork'
require 'pork/isolate'

module Pork
  module Shuffle
    def shuffle stat=Stat.new
      all_tests.keys.shuffle.each do |name|
        isolate(name, stat)
      end
      stat
    end
  end

  Executor.extend(Shuffle)
end
