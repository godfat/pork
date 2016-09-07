
module Pork
  class Env < Struct.new(:super_env, :before, :after)
    def initialize se=nil
      super(se, [], [])
    end

    def run_before context
      super_env && super_env.run_before(context)
      before.each{ |b| context.instance_eval(&b) }
    end

    def run_after context
      after.reverse_each{ |b| context.instance_eval(&b) }
      super_env && super_env.run_after(context)
    end
  end
end
