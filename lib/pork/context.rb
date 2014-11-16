
require 'pork/expect'
require 'pork/error'

module Pork
  module Context
    private
    def initialize desc
      @__pork__desc__ = desc
    end

    def expect *args, &block
      Expect.new(self.class.stat, *args, &block)
    end

    def skip
      raise Skip.new("Skipping #{@__pork__desc__}")
    end

    def flunk reason='Flunked'
      raise Error.new(reason)
    end

    def ok
      self.class.stat.incr_assertions
    end
  end
end
