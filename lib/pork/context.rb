
require 'pork/expect'
require 'pork/error'

module Pork
  module Context
    private
    def initialize desc, stat
      @__pork__desc__, @__pork__stat__ = desc, stat
    end

    def expect *args, &block
      Expect.new(@__pork__stat__, *args, &block)
    end

    def skip
      raise Skip.new("Skipping #{@__pork__desc__}")
    end

    def flunk reason='Flunked'
      raise Error.new(reason)
    end

    def ok
      @__pork__stat__.incr_assertions
    end
  end
end
