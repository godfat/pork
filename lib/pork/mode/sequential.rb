
require 'pork'

module Pork
  module Sequential
    def sequential stat=Stat.new, paths=nil
      if paths
        require 'pork/isolate'
        stat.prepare(paths)
        paths.inject(stat, &method(:isolate))
      else # maybe we could remove this mode if it's not faster and lighter
        sequential_with_env(stat) # XXX: doesn't work for PORK_REPORT=progress
      end
    end

    protected
    def sequential_with_env stat, super_env=nil
      env = Env.new(super_env)
      @tests.each do |(type, arg, test)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        when :describe
          arg.sequential_with_env(stat, env)
        when :would
          run(stat, arg, test, env)
        end
      end

      stat
    end
  end

  Executor.extend(Sequential)
end
