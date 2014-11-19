
require 'pork/expect'
require 'pork/error'

module Pork
  module Context
    private
    def expect *args, &block
      Expect.new(pork_stat, *args, &block)
    end

    def skip
      raise Skip.new
    end

    def flunk reason='Flunked'
      raise Error.new(reason)
    end

    def ok
      pork_stat.incr_assertions
    end
  end
end
