
require 'pork/stat'

require 'pork/more/bottomup_backtrace'
require 'pork/more/color'

Pork::Stat.__send__(:include, Pork::BottomupBacktrace)
Pork::Stat.__send__(:include, Pork::Color)
