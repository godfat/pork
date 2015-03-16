
require 'pork/executor'

module Kernel
  def should *args, &block
    stat = Thread.current.group.list.find{ |t| t[:pork_stat] }[:pork_stat]
    Pork::Expect.new(stat, self, *args, &block)
  end
end

module Pork
  module Should
    def execute mode, stat=Stat.new, *args
      thread = Thread.current
      original_group, group = thread.group, ThreadGroup.new
      group.add(thread)
      thread[:pork_stat] = stat
      super(mode, stat, *args)
    ensure
      original_group.add(thread)
    end
  end

  Executor.extend(Should)
end