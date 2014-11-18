
require 'pork/env'
require 'pork/stat'
require 'pork/error'
require 'pork/expect'

module Pork
  module Imp
    attr_reader :desc, :tests, :stat

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

    def execute io=$stdout, stat=Stat.new
      stat.start
      execute_with_parent(io, stat)
      self
    end

    private
    def init desc=''
      @desc, @tests, @stash = desc, [], {}
      @super_executor = ancestors[1..-1].find{ |a| a <= Executor }
    end

    def run desc, test, io, env
      assertions = stat.assertions
      context = new(desc)
      run_protected(desc, io) do
        env.run_before(context)
        context.instance_eval(&test)
        if assertions == stat.assertions
          raise Error.new('Missing assertions')
        end
        io.print '.'
      end
    ensure
      stat.incr_tests
      run_protected(desc, io){ env.run_after(context) }
    end

    def run_protected desc, io
      yield
    rescue Error, StandardError => e
      case e
      when Skip
        stat.incr_skips
        io.print 's'
      when Failure
        stat.add_failure(e, description_for("would #{desc}"))
        io.print 'F'
      when Error, StandardError
        stat.add_error(  e, description_for("would #{desc}"))
        io.print 'E'
      end
    end

    protected
    def execute_with_parent io=$stdout, stat=Stat.new, super_env=nil
      @stat, env = stat, Env.new(super_env)
      @tests.each do |(type, arg, test)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        when :describe
          arg.execute_with_parent(io, stat, env)
        when :would
          run(arg, test, io, env)
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
