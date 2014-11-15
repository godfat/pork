
require 'pork/expect'

module Kernel
  def should *args, &block
    Thread.current.group.list.first[:pork_executor].
      expect(self, *args, &block)
  end
end
