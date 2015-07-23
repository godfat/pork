
require 'pork/inspect'

module Pork
  class Expect < BasicObject
    instance_methods.each{ |m| undef_method(m) unless m =~ /^__|^object_id$/ }
    def initialize stat, object=nil, message=nil, message_lazy=nil, &checker
      @stat, @object, @negate = stat, object, false
      @message, @message_lazy = message, message_lazy
      satisfy(&checker) if checker
    end

    def method_missing msg, *args, &block
      satisfy(nil, Inspect.with(@object, msg, args, @negate)) do
        @object.public_send(msg, *args, &block)
      end
    end

    def satisfy desc=@object, desc_lazy=nil
      result = yield(@object)
      if !!result == @negate
        d =     desc_lazy &&     desc_lazy.call || desc
        m = @message_lazy && @message_lazy.call || @message
        ::Kernel.raise Failure.new("Expect #{d}\n#{m}".chomp)
      else
        @stat.incr_assertions
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

    def approx rhs, precision=10
      round(precision) == rhs.round(precision)
    end

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
    def __not__; if @negate == true then 'not ' else '' end; end
  end
end
