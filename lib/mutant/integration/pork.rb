
require 'pork'

module Mutant
  class Integration
    class Pork < Integration
      register 'pork'

      def self.build
        new
      end

      def run _
        start = Time.now
        out = StringIO.new
        $stdout.reopen(out)
        Dir['./test/test_*.rb'].each do |r|
          require r
        end
        out.rewind
        Result::Test.new(
          test: nil,
          mutation: nil,
          output: out.read,
          runtime: Time.now - start,
          passed: Pork.stats.failures + Pork.stats.errors == 0
        )
      rescue
        out.rewind
        Result::Test.new(
          test: nil,
          mutation: nil,
          output: out.read,
          runtime: Time.now - start,
          passed: false
        )
      end

      def all_tests
        ARGV.map{ |arg| Test.new(self, Expression.parse(arg)) }
      end
      memoize :all_tests
    end
  end
end
