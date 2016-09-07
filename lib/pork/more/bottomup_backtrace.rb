
module Pork
  module BottomupBacktrace
    private
    def backtrace *_
      super.reverse
    end
  end

  report_extensions << BottomupBacktrace
end
