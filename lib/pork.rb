
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
  def self.report_at_exit
    Pork.stats.start
    @report_at_exit ||= at_exit do
      stats.report
      exit stats.failures.size + stats.errors.size + ($! && 1).to_i
    end
  end
  # default to :auto while eliminating warnings for uninitialized ivar
  def self.inspect_failure_mode mode=nil; @mode = mode || @mode ||= :auto; end
  def self.inspect_failure *args
    lambda{ public_send("inspect_failure_#{inspect_failure_mode}", *args) }
  end

  def self.inspect_failure_auto object, msg, args, negate
    inspect_failure_inline(object, msg, args, negate)
  end

  def self.inspect_failure_inline object, msg, args, negate
    a = args.map(&:inspect).join(', ')
    "#{object.inspect}.#{msg}(#{a}) to return #{!negate}"
  end

  def self.inspect_failure_newline object, msg, args, negate
    a = args.map(&:inspect).join(', ')
    "\n#{object.inspect}.#{msg}(\n#{a}) to return #{!negate}"
  end

  def self.inspect_failure_diff object, msg, args, negate
    require 'tempfile'
    Tempfile.open('pork-expect') do |expect|
      Tempfile.open('pork-was') do |was|
        expect.puts(object.to_s)
        expect.close
        was.puts(args.map(&:to_s).join(",\n"))
        was.close
        name = "#{object.class}##{msg}(\n"
        "#{name}#{`diff #{expect.path} #{was.path}`}) to return #{!negate}"
      end
    end
  end

  module API
    module_function
    def before &block; Executor.before(&block); end
    def after  &block; Executor.after( &block); end
    def describe desc=:default, &suite; Executor.describe(desc, &suite); end
    def copy     desc=:default, &suite; Executor.copy(    desc, &suite); end
    def paste    desc=:default, *args ; Executor.paste(   desc, *args ); end
    def would    desc=:default, &test ; Executor.would(   desc, &test ); end
  end

  module Imp
    attr_reader :stash, :desc
    def before &block
      if block_given? then @before << block else @before end
    end
    def after  &block
      if block_given? then @after  << block else @after  end
    end
    def describe desc=:default, &suite
      Class.new(self){ init("#{desc}: ") }.module_eval(&suite)
    end
    def copy  desc=:default, &suite; stash[desc] = suite; end
    def paste desc=:default, *args
      module_exec(*args, &search_stash(desc))
    end
    def would desc=:default, &test
      assertions = Pork.stats.assertions
      context = new(desc)
      run_before(context)
      context.instance_eval(&test)
      if assertions == Pork.stats.assertions
        raise Error.new('Missing assertions')
      end
    rescue Error, StandardError => e
      case e
      when Skip
        Pork.stats.incr_skips
      when Failure
        Pork.stats.add_failure(e, description_for("would #{desc}"))
      when Error, StandardError
        Pork.stats.add_error(  e, description_for("would #{desc}"))
      end
    else
      print '.'
    ensure
      Pork.stats.incr_tests
      run_after(context)
    end

    protected
    def init desc=''
      @desc, @before, @after, @stash = desc, [], [], {}
    end
    def super_executor
      @super_executor ||= ancestors[1..-1].find{ |a| a <= Executor }
    end
    def search_stash desc
      stash[desc] or super_executor && super_executor.search_stash(desc)
    end
    def description_for name=''
      "#{desc}#{super_executor && super_executor.description_for}#{name}"
    end
    def run_before context
      super_executor && super_executor.run_before(context)
      before.each{ |b| context.instance_eval(&b) }
    end
    def run_after context
      super_executor && super_executor.run_after(context)
      after.each{ |b| context.instance_eval(&b) }
    end
  end

  class Executor < Struct.new(:desc)
    extend Pork::Imp, Pork::API
    init
    def skip                  ; raise Skip.new("Skipping #{desc}"); end
    def flunk reason='Flunked'; raise Error.new(reason)           ; end
    def ok                    ; Pork.stats.incr_assertions        ; end
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
      satisfy(nil, ::Pork.inspect_failure(@object, msg, args, @negate)) do
        @object.public_send(msg, *args, &block)
      end
    end

    def satisfy desc=@object, desc_lazy=nil
      result = yield(@object)
      if !!result == @negate
        d = desc_lazy && desc_lazy.call or desc
        ::Kernel.raise Failure.new("Expect #{d}\n#{@message}".chomp)
      else
        ::Pork.stats.incr_assertions
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
        data = ::Kernel.catch(msg) do
          if ::Kernel.block_given? then yield else @object.call end
          flag = false
        end
        flag && [msg, data]
      end
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
    def incr_assertions; @mutex.synchronize{ self.assertions += 1       }; end
    def incr_tests     ; @mutex.synchronize{ self.tests      += 1       }; end
    def incr_skips     ; @mutex.synchronize{ self.skips += 1; print('s')}; end
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
