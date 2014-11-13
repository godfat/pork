
require 'pork/imp'

module Pork
  class Executor < Struct.new(:desc)
    extend Pork::Imp
    init
    def skip                  ; raise Skip.new("Skipping #{desc}"); end
    def flunk reason='Flunked'; raise Error.new(reason)           ; end
    def ok                    ; self.class.stat.incr_assertions   ; end
  end
end
