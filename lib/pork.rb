
module Pork
  module API
    module_function
    def describe message, &block
      Pork::Executor.execute(self, message, block)
    end
  end

  class Executor
    extend Pork::API
    def self.execute caller, message, block
      parent = if caller.kind_of?(Class) then caller else self end
      Class.new(parent).module_eval(&block)
    end

    def self.would message, &block
      new.instance_eval(&block)
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
        ::Kernel.raise "BAD, expect #{desc}"
      when !@negate
        ::Kernel.puts "GOOD"
      else
        ::Kernel.raise "BAD, expect #{bool.inspect} to be true or false"
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
      satisfy("#{__not}raising one of: #{exceptions}") do
        begin
          @object.call
        rescue *exceptions
          true
        else
          false
        end
      end
    end

    def throw msg
      satisfy("#{__not}throwing #{msg}") do
        flag = true
        ::Kernel.catch(msg) do
          @object.call
          flag = false
        end
        flag
      end
    end

    private
    def __not
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
