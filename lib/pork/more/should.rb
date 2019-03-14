
module Kernel
  def should *args, &block
    stat = Thread.current.group.list.find do |t|
      t.thread_variable_get(:pork_stat)
    end.thread_variable_get(:pork_stat)
    Pork::Expect.new(stat, self, *args, &block)
  end
end

module Pork
  module Should
    def execute stat=Stat.new, *args
      thread = Thread.current
      original_group, group = thread.group, ThreadGroup.new
      original_stat = thread.thread_variable_get(:pork_stat)
      group.add(thread)
      thread.thread_variable_set(:pork_stat, stat)
      super(stat, *args)
    ensure
      thread.thread_variable_set(:pork_stat, original_stat)
      original_group.add(thread)
    end
  end

  execute_extensions << Should
end
