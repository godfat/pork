
require 'pork/imp'
require 'pork/isolate'
require 'pork/context'

module Pork
  class Executor < Struct.new(:pork_stat, :pork_description)
    # we don't want this method from Struct.new, it's confusing when
    # pork/isolate was not loaded. (i.e. isolate would override it anyway)
    singleton_class.superclass.send(:remove_method, :[])

    extend Isolate, Imp
    include Context
    init
  end
end
