
require 'thread'

module Kernel
  def should message=nil, &checker
    Pork::Should.new(self, message, &checker)
  end
end

module Pork
  Error   = Class.new(Exception)
  Failure = Class.new(Error)
  Skip    = Class.new(Error)

  def self.stats ; @stats ||= Stats.new; end
  def self.reset ; @stats   = nil      ; end
  def self.report; stats.report; reset ; end

  module API
    module_function
    def before &block; Executor.before(&block); end
    def after  &block; Executor.after( &block); end
    def describe desc=:default, &suite; Executor.describe(desc, &suite); end
    def copy     desc=:default, &suite; Executor.copy(    desc, &suite); end
    def paste    desc=:default        ; Executor.paste(   desc, &suite); end
  end

  module Imp
    attr_reader :stash
    def before &block
      if block_given? then @before << block else @before end
    end
    def after  &block
      if block_given? then @after  << block else @after  end
    end
    def describe desc=:default, &suite
      Pork.stats.start
      execute(self, desc, &suite)
      Pork.stats.tests += 1
    end
    def copy  desc=:default, &suite; stash[desc] = suite; end
    def paste desc=:default
      stashes = [self, super_executor].compact.map(&:stash)
      instance_eval(&stashes.find{ |s| s[desc] }[desc])
    end
    def would name=:default, &test
      assertions = Pork.stats.assertions
      context = new(name)
      run_before(context)
      context.instance_eval(&test)
      if assertions == Pork.stats.assertions
        raise Error.new('Missing assertions')
      end
    rescue Error, StandardError => e
      case e
      when Skip
        Pork.stats.skips += 1
      when Failure
        Pork.stats.add_failure(e, description_for("would #{name}"))
      when Error, StandardError
        Pork.stats.add_error(  e, description_for("would #{name}"))
      end
    else
      print '.'
    ensure
      run_after(context)
    end

    protected
    def init desc=''
      @desc, @before, @after, @stash = desc, [], [], {}
    end
    def super_executor
      @super_executor ||= ancestors[1..-1].find{ |a| a <= Executor }
    end
    def execute caller, desc, &suite
      parent = if caller.kind_of?(Class) then caller else self end
      Class.new(parent){ init("#{desc}: ") }.module_eval(&suite)
    end
    def description_for name=''
      "#{@desc}#{super_executor && super_executor.description_for}#{name}"
    end
    def run_before context
      super_executor.run_before(context) if super_executor
      before.each{ |b| context.instance_eval(&b) }
    end
    def run_after context
      super_executor.run_after(context) if super_executor
      after.each{ |b| context.instance_eval(&b) }
    end
  end

  class Executor < Struct.new(:name)
    extend Pork::Imp, Pork::API
    init
    def skip; raise Skip.new("Skipping #{name}"); end
  end

  class Should < BasicObject
    instance_methods.each{ |m| undef_method(m) unless m =~ /^__|^object_id$/ }

    def initialize object, message, &checker
      @object = object
      @negate = false
      @message = message
      satisfy(&checker) if checker
    end

    def method_missing msg, *args, &block
      satisfy("#{@object.inspect}.#{msg}(#{args.join(', ')}) to" \
              " return #{!@negate}") do
        @object.public_send(msg, *args, &block)
      end
    end

    def satisfy desc=@object
      result = yield(@object)
      if !!result == @negate
        ::Kernel.raise Failure.new("Expect #{desc}\n#{@message}".chomp)
      else
        ::Pork.stats.assertions += 1
      end
      result
    end

    def not &checker
      @negate = !@negate
      satisfy(&checker) if checker
      self
    end

    def eq  rhs; self == rhs; end
    def lt  rhs; self <  rhs; end
    def gt  rhs; self >  rhs; end
    def lte rhs; self <= rhs; end
    def gte rhs; self >= rhs; end

    def raise exception=::RuntimeError
      satisfy("#{__not__}raising #{exception}") do
        begin
          if ::Kernel.block_given? then yield else @object.call end
        rescue exception => e
          e
        else
          false
        end
      end
    end

    def throw msg
      satisfy("#{__not__}throwing #{msg}") do
        flag = true
        ::Kernel.catch(msg) do
          if ::Kernel.block_given? then yield else @object.call end
          flag = false
        end
        flag
      end
    end

    def flunk reason='Flunked'
      ::Kernel.raise Error.new(reason)
    end

    private
    def __not__
      if @negate == true
        'not '
      else
        ''
      end
    end
  end

  class Stats < Struct.new(:tests, :assertions, :skips, :failures, :errors)
    def initialize
      @mutex = Mutex.new
      super(0, 0, 0, [], [])
    end
    def assertions= num; @mutex.synchronize{ super                    }; end
    def tests=      num; @mutex.synchronize{ super                    }; end
    def skips=      num; @mutex.synchronize{ super        ; print('s')}; end
    def add_failure *e ; @mutex.synchronize{ failures << e; print('F')}; end
    def add_error   *e ; @mutex.synchronize{ errors   << e; print('E')}; end
    def numbers
      [tests, assertions, failures.size, errors.size, skips]
    end
    def start
      @start ||= Time.now
    end
    def report
      puts
      puts (failures + errors).map{ |(e, m)|
        "\n#{m}\n#{e.class}: #{e.message}\n  #{backtrace(e)}"
      }
      printf("\nFinished in %f seconds.\n", Time.now - @start)
      printf("%d tests, %d assertions, %d failures, %d errors, %d skips\n",
             *numbers)
    end
    private
    def backtrace e
      if $VERBOSE
        e.backtrace
      else
        e.backtrace.reject{ |line| line =~ %r{/pork\.rb:\d+} }
      end.join("\n  ")
    end
  end
end
