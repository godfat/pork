
require 'thread'

module Pork
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
  end

  def self.stats; @stats ||= Stats.new; end
  def self.start; @start ||= Time.now ; end
  def self.report
    puts
    puts (stats.failures + stats.errors).map{ |(e, m)|
      "\n#{m}\n#{e.class}: #{e.message}\n  " +
      e.backtrace.reject{ |line| line =~ %r{/pork\.rb:\d+} }.join("\n  ")
    }
    printf("\nFinished in %f seconds.\n", Time.now - start)
    printf("%d tests, %d assertions, %d failures, %d errors, %d skips\n",
           *stats.numbers)
  end

  module API
    module_function
    def describe desc, &block
      Pork.start
      Pork::Executor.execute(self, desc, &block)
      Pork.stats.tests += 1
    end
  end

  Error   = Class.new(Exception)
  Failure = Class.new(Error)
  Skip    = Class.new(Error)

  class Executor < Struct.new(:name)
    extend Pork::API
    @desc = ''
    def self.execute caller, desc, &block
      parent = if caller.kind_of?(Class) then caller else self end
      Class.new(parent){ @desc = "#{desc}:" }.module_eval(&block)
    end

    def self.would name, &block
      assertions = Pork.stats.assertions
      new(name).instance_eval(&block)
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
    end

    def self.description_for name=''
      supername =
        if anc = ancestors[1..-1].find{ |a| a.respond_to?(:description_for) }
          " #{anc.description_for}"
        else
          ''
        end
      "#{@desc}#{supername}#{name}"
    end

    def skip
      raise Skip.new("Skipping #{name}")
    end
  end

  class Should < BasicObject
    instance_methods.each{ |m| undef_method(m) unless m =~ /^__|^object_id$/ }

    def initialize object, message
      @object = object
      @negate = false
      @message = message
    end

    def method_missing msg, *args, &block
      satisfy("#{@object}.#{msg}(#{args.join(', ')}) to" \
              " return #{!@negate}\n#{@message}") do
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
  def should message=nil
    Pork::Should.new(self, message)
  end
end
