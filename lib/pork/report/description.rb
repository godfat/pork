
require 'pork/report/dot'

module Pork
  class Description < Dot
    attr_accessor :last_suite

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
      self.last_suite ||= Suite
      suite = context.class
      levels = suite.ancestors.drop(1).count{ |a| a <= Suite }

      if suite != Suite && last_suite != suite
        io.puts "#{'  ' * (levels - 1)}#{suite.desc}"
      end

      io.print "#{'  ' * levels}#{context.pork_description}"

      self.last_suite = suite
    end

    def case_end
      io.puts
    end
  end
end
