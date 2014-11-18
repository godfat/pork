
require 'pork'
require 'pork/isolate'

module Pork
  module Shuffle
    def shuffle io=$stdout, stat=Stat.new
      all_tests.keys.shuffle.each do |name|
        isolate(name, io, stat)
      end
      stat
    end
  end

  Executor.extend(Shuffle)
end
