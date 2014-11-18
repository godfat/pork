
require 'pork'
require 'pork/executor'

module Pork
  module Isolate
    def all_tests
      @all_tests ||= Hash[build_all_tests]
    end

    def isolate name, io=$stdout, stat=Stat.new
      execute_with_isolation(all_tests[name], io, stat)
      stat
    end

    protected
    def build_all_tests paths=[]
      @tests.flat_map.with_index do |(type, arg, _), index|
        case type
        when :describe
          arg.build_all_tests(paths + [index])
        when :would
          [["#{desc.chomp(': ')} #{arg} ##{index} ", paths + [index]]]
        else
          []
        end
      end
    end

    def execute_with_isolation paths, io, stat, super_env=nil
      env = Env.new(super_env)
      idx = paths.first

      @tests.first(idx).each do |(type, arg, _)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        end
      end

      if paths.size == 1
        _, desc, test = @tests[idx]
        run(desc, test, io, env)
      else
        @tests[idx][1].
          execute_with_isolation(paths.drop(1), io, stat, env)
      end
    end
  end

  Executor.extend(Isolate)
end
