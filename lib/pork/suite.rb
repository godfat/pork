
require 'fiber'

require 'pork/runner'
require 'pork/context'

module Pork
  class Suite < Struct.new(:pork_stat, :pork_description, :pork_fibers)
    module Imp
      attr_reader :desc, :tests

      def before &block; @tests << [:before, block]; end
      def after  &block; @tests << [:after , block]; end

      def around &block
        before do
          fiber = Fiber.new{ instance_exec(Fiber.method(:yield), &block) }
          pork_fibers << fiber
          fiber.resume
        end

        after do
          fiber = pork_fibers.pop
          fiber.resume if fiber.alive?
        end
      end

      def copy  desc=:default, &suite
        @stash[desc] = suite
      end
      def paste desc=:default, *args
        module_exec(*args, &search_stash(desc))
      end

      def describe desc=:default, opts={}, &suite
        executor = Class.new(self){ init(desc) }
        executor.module_eval(&suite)
        @tests << [:describe, executor, suite, opts]
      end

      def would desc=:default, opts={}, &test
        raise ArgumentError.new("no block given") unless test
        @tests << [:would   , desc    , test, opts]
      end

      def description_for name=''
        if @super_executor
          "#{@super_executor.description_for}#{@desc}: #{name}"
        else
          name
        end
      end

      def run *args
        Runner.new(self, Pork.reseed, *args).run
      end

      private
      def init desc=''
        @desc, @tests, @stash = desc, [], {}
        @super_executor = ancestors[1..-1].find{ |a| a <= Suite }
      end

      protected
      def search_stash desc
        @stash[desc] or @super_executor && @super_executor.search_stash(desc)
      end
    end

    extend Imp
    include Context
    init
  end
end
