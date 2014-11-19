
require 'pork/expect'
require 'pork/error'

module Pork
  module Context
    private
    def initialize stat
      @__pork__stat__ = stat
    end

    def expect *args, &block
      Expect.new(@__pork__stat__, *args, &block)
    end

    def skip
      raise Skip.new
    end

    def flunk reason='Flunked'
      raise Error.new(reason)
    end

    def ok
      @__pork__stat__.incr_assertions
    end
  end
end
