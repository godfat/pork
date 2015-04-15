
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

    def would desc=:default, opts={}, &test
      @tests << [:would, desc, test, opts]
    end

    def execute mode, *args
      require "pork/mode/#{mode}"
      if args.size == 1 || mode.to_s != 'sequential'
        send(mode, *args)
      else # cannot run sequential tests for specific paths
        shuffled(*args)
      end
    end

    private
    def init desc=''
      @desc, @tests, @stash = desc, [], {}
      @super_executor = ancestors[1..-1].find{ |a| a <= Executor }
    end

    def run desc, test, stat, env
      assertions = stat.assertions
      context = new(stat)
      run_protected(desc, stat, test) do
        env.run_before(context)
        context.instance_eval(&test)
        if assertions == stat.assertions
          raise Error.new('Missing assertions')
        end
        stat.case_pass
      end
    ensure
      stat.incr_tests
      run_protected(desc, stat, test){ env.run_after(context) }
    end

    def run_protected desc, stat, test
      yield
    rescue Error, StandardError => e
      case e
      when Skip
        stat.incr_skips
        stat.case_skip
      else
        err = [e, description_for("would #{desc}"), test.source_location]
        case e
        when Failure
          stat.add_failure(err)
          stat.case_failed
        when Error, StandardError
          stat.add_error(err)
          stat.case_errored
        end
      end
    end

    protected
    def search_stash desc
      @stash[desc] or @super_executor && @super_executor.search_stash(desc)
    end

    def description_for name=''
      "#{@super_executor && @super_executor.description_for}#{@desc}#{name}"
    end
  end
end
