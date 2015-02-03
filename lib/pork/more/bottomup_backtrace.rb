
module Pork
  module BottomupBacktrace
    private
    def backtrace err
      super.reverse
    end
  end
end
