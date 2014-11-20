
require 'pork/executor'

module Kernel
  def should *args, &block
    Pork::Expect.new(
      Thread.current.group.list.first[:pork_stat], self, *args, &block)
  end
end

module Pork
  module Should
    def execute stat=Stat.new
      thread = Thread.current
      original_group, group = thread.group, ThreadGroup.new
      group.add(thread)
      thread[:pork_stat] = stat
      super
    ensure
      original_group.add(thread)
    end
  end

  Executor.extend(Should)
end
