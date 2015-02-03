
require 'pork/stat'

Pork::Stat.__send__(:include, Pork::BottomupBacktrace)
Pork::Stat.__send__(:include, Pork::Color)
