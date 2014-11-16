
require 'pork/executor'

module Kernel
  def should *args, &block
    Thread.current.group.list.first[:pork_executor].
      expect(self, *args, &block)
  end
end

module Pork
  module Ext
    def execute *args
      thread = Thread.current
      original_group, group = thread.group, ThreadGroup.new
      group.add(thread)
      thread[:pork_executor] = self
      super
    ensure
      original_group.add(thread)
    end
  end

  Executor.extend(Ext)
end
