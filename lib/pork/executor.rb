
require 'pork/imp'
require 'pork/context'

module Pork
  class Executor < Struct.new(:pork_stat, :pork_description)
    extend Imp
    include Context
    init
  end
end
