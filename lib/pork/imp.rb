
require 'pork/stat'
require 'pork/error'
require 'pork/expect'

module Pork
  module Imp
    attr_reader :desc, :tests, :io, :stat

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

    def passed?
      stat.failures.size + stat.errors.size == 0
    end

    def all_tests
      @all_tests ||= Hash[build_all_tests]
    end

    def isolate name
      executor = Class.new do
        extend Imp
        include Context
        init(name)
      end

      paths = all_tests[name]

      _, desc, block = paths[0..-2].inject(tests) do |ts, index|
        ts.first(index).each do |(type, block, _)|
          case type
          when :before
            executor.before(&block)
          when :after
            executor.after(&block)
          end
        end
        ts[index][1].tests
      end[paths.last]

      executor.would(desc, &block)
      executor
    end

    private
    def init desc=''
      @desc, @tests, @stash, @before, @after = desc, [], {}, [], []
      @super_executor = ancestors[1..-1].find{ |a| a <= Executor }
    end

    def run desc, test
      assertions = stat.assertions
      context = new(desc)
      run_protected(desc) do
        run_before(context)
        context.instance_eval(&test)
        if assertions == stat.assertions
          raise Error.new('Missing assertions')
        end
        io.print '.'
      end
    ensure
      stat.incr_tests
      run_protected(desc){ run_after(context) }
    end

    def run_protected desc
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
    def execute_with_parent io=$stdout, stat=Stat.new
      @stat, @io = stat, io
      @tests.each do |(type, arg, test)|
        case type
        when :before
          @before << arg
        when :after
          @after  << arg
        when :describe
          arg.execute_with_parent(io, stat)
        when :would
          run(arg, test)
        end
      end
    end

    def search_stash desc
      @stash[desc] or @super_executor && @super_executor.search_stash(desc)
    end

    def run_before context
      @super_executor && @super_executor.run_before(context)
      @before.each{ |b| context.instance_eval(&b) }
    end

    def run_after context
      @super_executor && @super_executor.run_after(context)
      @after.each{ |b| context.instance_eval(&b) }
    end

    def description_for name=''
      "#{@desc}#{@super_executor && @super_executor.description_for}#{name}"
    end

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
  end
end
