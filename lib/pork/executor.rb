
require 'pork/suite'
require 'pork/isolator'

module Pork
  class Executor < Struct.new(:isolator)
    def self.[] index
      Isolator[][index]
    end

    def self.execute mode: Pork.execute_mode,
                     stat: Pork.stat,
                     suite: Suite,
                     isolator: Isolator[suite],
                     paths: isolator.all_paths
      require "pork/mode/#{mode}"
      Pork.const_get(mode.capitalize).new(isolator).execute(stat, paths)
    end

    def initialize new_isolator
      super(new_isolator)
      extensions = Pork.execute_extensions
      extend(*extensions.reverse) if extensions.any?
    end

    def execute stat=Stat.new, paths=isolator.all_paths
      raise NotImplementedError
    end
  end
end
