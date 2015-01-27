
require 'pork'
require 'pork/executor'

module Pork
  module Isolate
    def all_tests
      @all_tests ||= build_all_tests
    end

    def isolate path, stat=Stat.new
      execute(stat) do |s|
        execute_with_isolation(path, s)
      end
    end

    protected
    def build_all_tests result=Hash.new{|r,k|r[k]=[]}, path=[]
      @tests.each_with_index.inject(result) do |r, ((type, arg, _), index)|
        current = path + [index]
        case type
        when :describe
          arg.build_all_tests(r, current)
        when :would
          r[description_for("would #{arg}")] << current
        end
        r
      end
    end

    def execute_with_isolation path, stat, super_env=nil
      env = Env.new(super_env)
      idx = path.first

      @tests.first(idx).each do |(type, arg, _)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        end
      end

      if path.size == 1
        _, desc, test = @tests[idx]
        run(desc, test, stat, env)
      else
        @tests[idx][1].execute_with_isolation(path.drop(1), stat, env)
      end
    end
  end

  Executor.extend(Isolate)
end
