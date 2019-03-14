
require 'pork/error'

module Pork
  class Runner < Struct.new(:suite, :seed, :stat, :desc, :test, :env)
    def run
      assertions = stat.assertions
      context = suite.new(stat, desc, [])

      stat.reporter.case_start(context)

      passed = protected do
        env.run_before(context)
        context.instance_eval(&test)
      end

      protected{ env.run_after(context) }

      if passed
        if assertions == stat.assertions
          protected{ raise Error.new('Missing assertions') }
        else
          stat.reporter.case_pass
        end
      end

      stat.incr_tests
      stat.reporter.case_end
    end

    private
    def protected
      yield
      true
    rescue *stat.protected_exceptions => e
      case e
      when Skip
        stat.incr_skips
        stat.reporter.case_skip
      else
        err = [e, suite.description_for("would #{desc}"), test, seed]
        case e
        when Failure
          stat.add_failure(err)
          stat.reporter.case_failed
        else
          stat.add_error(err)
          stat.reporter.case_errored
        end
      end
      false
    end
  end
end
