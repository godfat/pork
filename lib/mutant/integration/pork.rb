
require 'pork'

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
        # TODO: how do we load tests?
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
      def run(_)
        # ::Pork::Executor.execute
        Result::Test.new(
          test:     nil,
          mutation: nil,
          output:   '',
          runtime:  Time.now - Time.now, #::Pork::Executor.stat.start,
          passed:   false#::Pork::Executor.stat.failures +
                    #  ::Pork::Executor.stat.errors == 0
        )
      end

      # Return all available tests
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def all_tests
        # [Test.new(self, Expression.parse(ARGV.first))]
        []
      end
      memoize :all_tests

    end # Pork

  end # Integration
end # Mutant
