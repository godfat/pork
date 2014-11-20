
require 'pork/error'
require 'pork/executor'

module Kernel
  def should *args, &block
    stat = Thread.current.group.list.first[:pork_stat]
    raise Pork::Bug.new(
      "No Stat set. Thread list: #{Thread.current.group.list}") if stat.nil?
    Pork::Expect.new(stat, self, *args, &block)
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
