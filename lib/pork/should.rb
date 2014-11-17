
require 'pork/executor'

module Kernel
  def should *args, &block
    Pork::Expect.new(
      Thread.current.group.list.first[:pork_executor].stat,
      self, *args, &block)
  end
end

module Pork
  module Should
    def execute *args
      thread = Thread.current
      original_group, group = thread.group, ThreadGroup.new
      group.add(thread)
      thread[:pork_executor] = self
      super
    ensure
      original_group.add(thread)
    end

    def stat
      executor = Thread.current.group.list.first[:pork_executor]
      if self == executor
        super
      else
        executor.stat
      end
    end
  end

  Executor.extend(Should)
end
