
require 'pork'

module Pork
  module Sequential
    def sequential stat=Stat.new, super_env=nil
      env = Env.new(super_env)
      @tests.each do |(type, arg, test)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        when :describe
          arg.sequential(stat, env)
        when :would
          run(stat, arg, test, env)
        end
      end

      stat
    end
  end

  Executor.extend(Sequential)
end
