
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

  class Should < Struct.new(:object)
    def == rhs
      raise "BAD, #{object} != #{rhs}" if object != rhs
      puts "GOOD"
    end
  end
end

module Kernel
  def should
    Pork::Should.new(self)
  end
end
