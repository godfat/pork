
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
    end

    def method_missing msg, *args, &block
      if @object.public_send(msg, *args, &block)
        ::Kernel.puts "GOOD"
      else
        ::Kernel.raise "BAD, #{@object}.#{msg}(#{args.join(', ')})"
      end
    end
  end
end

module Kernel
  def should
    Pork::Should.new(self)
  end
end
