
module Pork
  class Executor < Struct.new(:isolator)
    def initialize
      extensions = Pork.execute_extensions
      extend(*extensions.reverse) if extensions.any?
    end
  end
end
