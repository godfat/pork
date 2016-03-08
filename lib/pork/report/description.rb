
require 'pork/report/dot'

module Pork
  class Description < Dot
    attr_accessor :last_executor

    def msg_pass
      msg = "\ro"
      if respond_to?(:green, true)
        green(msg)
      else
        msg
      end
    end

    def msg_skip   ; "\r#{super}"; end
    def msg_failed ; "\r#{super}"; end
    def msg_errored; "\r#{super}"; end

    def case_start context
      self.last_executor ||= Executor
      executor = context.class
      levels = executor.ancestors.drop(1).count{ |a| a <= Executor }

      if executor != Executor && last_executor != executor
        io.puts "#{'  ' * (levels - 1)}#{executor.desc}"
      end

      io.print "#{'  ' * levels}#{context.pork_description}"

      self.last_executor = executor
    end

    def case_end
      io.puts
    end
  end
end
