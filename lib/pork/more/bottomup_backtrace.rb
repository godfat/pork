
require 'pork'

module Pork
  module BottomupBacktrace
    private
    def backtrace *_
      super.reverse
    end
  end

  reporter_extensions << BottomupBacktrace
end
