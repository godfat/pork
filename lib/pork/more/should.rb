
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
      original_stat = thread[:pork_stat]
      group.add(thread)
      thread[:pork_stat] = stat
      super(mode, stat, *args)
    ensure
      thread[:pork_stat] = original_stat
      original_group.add(thread)
    end
  end
end
