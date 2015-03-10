
require 'pork/stat'

module Pork
  module BottomupBacktrace
    private
    def backtrace err
      super.reverse
    end
  end

  Pork::Stat.__send__(:include, Pork::BottomupBacktrace)
end
