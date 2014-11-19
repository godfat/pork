
require 'pork/imp'
require 'pork/context'

module Pork
  class Executor < Struct.new(:pork_stat)
    extend Imp
    include Context
    init
  end
end
