
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

    def describe desc=:default, opts={}, &suite
      executor = Class.new(self){ init(desc) }
      executor.module_eval(&suite)
      @tests << [:describe, executor, suite, opts]
    end

    def would desc=:default, opts={}, &test
      raise ArgumentError.new("no block given") unless test
      @tests << [:would   , desc    , test, opts]
    end

    def execute mode, *args
      require "pork/mode/#{mode}"
      public_send(mode, *args)
    end

    private
    def init desc=''
      @desc, @tests, @stash = desc, [], {}
      @super_executor = ancestors[1..-1].find{ |a| a <= Executor }
    end

    def run stat, desc, test, env
      assertions = stat.assertions
      context = new(stat, desc)
      seed = Pork.reseed
      stat.reporter.case_start(context)
      run_protected(stat, desc, test, seed) do
        env.run_before(context)
        context.instance_eval(&test)
        raise Error.new('Missing assertions') if assertions == stat.assertions
        stat.reporter.case_pass
      end
    ensure
      stat.incr_tests
      run_protected(stat, desc, test, seed){ env.run_after(context) }
      stat.reporter.case_end
    end

    def run_protected stat, desc, test, seed
      yield
    rescue *stat.protected_exceptions => e
      case e
      when Skip
        stat.incr_skips
        stat.reporter.case_skip
      else
        err = [e, description_for("would #{desc}"), test, seed]
        case e
        when Failure
          stat.add_failure(err)
          stat.reporter.case_failed
        else
          stat.add_error(err)
          stat.reporter.case_errored
        end
      end
    end

    protected
    def search_stash desc
      @stash[desc] or @super_executor && @super_executor.search_stash(desc)
    end

    def description_for name=''
      if @super_executor
        "#{@super_executor.description_for}#{@desc}: #{name}"
      else
        name
      end
    end
  end
end
