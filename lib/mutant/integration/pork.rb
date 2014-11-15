
require 'pork'
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
      def run(_)
        out = StringIO.new
        ::Pork::Executor.execute(out)
        Result::Test.new(
          test:     nil,
          mutation: nil,
          output:   out.string,
          runtime:  Time.now - ::Pork::Executor.stat.start,
          passed:   ::Pork::Executor.stat.failures +
                      ::Pork::Executor.stat.errors == 0
        )
      end

      # Return all available tests
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def all_tests
        [Test.new(self, Expression.parse(ARGV.first))]
      end
      memoize :all_tests

    end # Pork

  end # Integration
end # Mutant
