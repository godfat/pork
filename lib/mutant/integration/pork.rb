
require 'pork'
require 'pork/isolate'
require 'stringio'

module Mutant
  class Integration
    class Pork < self
      register 'pork'

      # Return integration compatible to currently loaded pork
      #
      # @return [Integration]
      #
      # @api private
      #
      def self.build
        new
      end

      # Setup pork integration
      #
      # @return [self]
      #
      # @api private
      #
      def setup
        Dir['test/**/test_*.rb'].each do |path|
          require "./#{path}"
        end
        ::Pork.autorun(false)
        self
      end
      memoize :setup

      # Return report for test
      #
      # @param [Pork::Test] test
      #
      # @return [Test::Result]
      #
      # @api private
      #
      # rubocop:disable MethodLength
      #
      def run(test)
        executor = ::Pork::Executor.isolate(test.expression.syntax)
        out = StringIO.new
        executor.execute(out)

        Result::Test.new(
          test:     nil,
          mutation: nil,
          output:   out.string,
          runtime:  Time.now - executor.stat.start,
          passed:   executor.passed?
        )
      end

      # Return all available tests
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def all_tests
        ::Pork::Executor.all_tests.keys.inject([]) do |tests, description|
          expression = Expression.try_parse(description) or next tests
          tests << Test.new(self, expression)
        end
      end
      memoize :all_tests

    end # Pork

  end # Integration
end # Mutant
