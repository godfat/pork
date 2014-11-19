
require 'pork/env'
require 'pork/stat'
require 'pork/error'
require 'pork/expect'

module Pork
  module Imp
    attr_reader :desc, :tests

    def before &block; @tests << [:before, block]; end
    def after  &block; @tests << [:after , block]; end

    def copy  desc=:default, &suite
      @stash[desc] = suite
    end
    def paste desc=:default, *args
      module_exec(*args, &search_stash(desc))
    end

    def describe desc=:default, &suite
      executor = Class.new(self){ init("#{desc}: ") }
      executor.module_eval(&suite)
      @tests << [:describe, executor]
    end

    def would desc=:default, &test
      @tests << [:would, desc, test]
    end

    def execute stat=Stat.new
      if block_given?
        yield(stat)
      else
        execute_with_parent(stat)
      end
      stat
    end

    private
    def init desc=''
      @desc, @tests, @stash = desc, [], {}
      @super_executor = ancestors[1..-1].find{ |a| a <= Executor }
    end

    def run desc, test, stat, env
      assertions = stat.assertions
      context = new(stat)
      run_protected(desc, stat) do
        env.run_before(context)
        context.instance_eval(&test)
        if assertions == stat.assertions
          raise Error.new('Missing assertions')
        end
        stat.io.print '.'
      end
    ensure
      stat.incr_tests
      run_protected(desc, stat){ env.run_after(context) }
    end

    def run_protected desc, stat
      yield
    rescue Error, StandardError => e
      case e
      when Skip
        stat.incr_skips
        stat.io.print 's'
      when Failure
        stat.add_failure(e, description_for("would #{desc}"))
        stat.io.print 'F'
      when Error, StandardError
        stat.add_error(  e, description_for("would #{desc}"))
        stat.io.print 'E'
      end
    end

    protected
    def execute_with_parent stat, super_env=nil
      env = Env.new(super_env)
      @tests.each do |(type, arg, test)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        when :describe
          arg.execute_with_parent(stat, env)
        when :would
          run(arg, test, stat, env)
        end
      end
    end

    def search_stash desc
      @stash[desc] or @super_executor && @super_executor.search_stash(desc)
    end

    def description_for name=''
      "#{@desc}#{@super_executor && @super_executor.description_for}#{name}"
    end
  end
end
