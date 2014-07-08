
require 'thread'

module Pork
  class Stats < Struct.new(:tests, :assertions, :failures, :errors, :skips)
    def initialize
      @mutex = Mutex.new
      super(0, 0, 0, 0, 0)
    end
    def assertions= num; @mutex.synchronize{ super }            ; end
    def tests=      num; @mutex.synchronize{ super }            ; end
    def failures=   num; @mutex.synchronize{ super; print('F') }; end
    def errors=     num; @mutex.synchronize{ super; print('E') }; end
    def skips=      num; @mutex.synchronize{ super; print('S') }; end
  end

  def self.stats; @stats ||= Stats.new; end
  def self.start; @start ||= Time.now ; end
  def self.report
    puts
    printf("Finished in %f seconds.\n\n", Time.now - start)
    printf("%d tests, %d assertions, %d failures, %d errors, %d skips\n",
           *stats.to_a)
  end

  module API
    module_function
    def describe message='', &block
      Pork.start
      Pork::Executor.execute(self, message, block)
      Pork.stats.tests += 1
    end
  end

  Error   = Class.new(Exception)
  Failure = Class.new(Error)
  Skip    = Class.new(Error)

  class Executor < Struct.new(:message)
    extend Pork::API
    def self.execute caller, message, block
      parent = if caller.kind_of?(Class) then caller else self end
      Class.new(parent).module_eval(&block)
    end

    def self.would message='Unnamed Test', &block
      assertions = Pork.stats.assertions
      new(message).instance_eval(&block)
      if assertions == Pork.stats.assertions
        raise Error.new("Missing assertions for #{message}")
      end
    rescue Error, StandardError => e
      case e
      when Skip
        Pork.stats.skips += 1
      when Failure
        Pork.stats.failures += 1
      when Error, StandardError
        Pork.stats.errors += 1
      end
    else
      print '.'
    end

    def skip
      raise Skip.new("Skipping #{message}")
    end
  end

  class Should < BasicObject
    instance_methods.each{ |m| undef_method(m) unless m =~ /^__|^object_id$/ }

    def initialize object
      @object = object
      @negate = false
    end

    def method_missing msg, *args, &block
      satisfy("#{@object}.#{msg}(#{args.join(', ')}) returns #{!@negate}") do
        @object.public_send(msg, *args, &block)
      end
    end

    def satisfy desc=@object
      case bool = yield
      when @negate
        ::Kernel.raise Failure.new("Expect #{desc}")
      when !@negate
        ::Pork.stats.assertions += 1
      else
        ::Kernel.raise Error.new("Expect #{bool.inspect} to be true or false")
      end
    end

    def not
      @negate = !@negate
      self
    end

    def eq rhs
      self == rhs
    end

    def raise *exceptions
      satisfy("#{__not__}raising one of: #{exceptions}") do
        begin
          @object.call
        rescue *exceptions
          true
        rescue
          false
        else
          false
        end
      end
    end

    def throw msg
      satisfy("#{__not__}throwing #{msg}") do
        flag = true
        ::Kernel.catch(msg) do
          @object.call
          flag = false
        end
        flag
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
end

module Kernel
  def should
    Pork::Should.new(self)
  end
end
