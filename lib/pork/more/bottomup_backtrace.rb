
require 'pork/stat'

module Pork
  module BottomupBacktrace
    private
    def backtrace *_
      super.reverse
    end
  end

  Pork::Stat.__send__(:include, Pork::BottomupBacktrace)
end
