
require 'pork/expect'

module Kernel
  def should *args, &block
    Thread.current[:pork_executor].expect(self, *args, &block)
  end
end
