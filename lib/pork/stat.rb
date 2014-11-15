
require 'thread'

module Pork
  class Stat < Struct.new(:tests, :assertions, :skips, :failures, :errors)
    def initialize
      @mutex = Mutex.new
      super(0, 0, 0, [], [])
    end
    def incr_assertions; @mutex.synchronize{ self.assertions += 1       }; end
    def incr_tests     ; @mutex.synchronize{ self.tests      += 1       }; end
    def incr_skips     ; @mutex.synchronize{ self.skips += 1; print('s')}; end
    def add_failure *e ; @mutex.synchronize{ failures << e; print('F')}; end
    def add_error   *e ; @mutex.synchronize{ errors   << e; print('E')}; end
    def numbers; [tests, assertions, failures.size, errors.size, skips]; end
    def start  ; @start ||= Time.now                                   ; end
    def report
      puts
      puts (failures + errors).map{ |(e, m)|
        "\n#{m}\n#{e.class}: #{e.message}\n  #{backtrace(e)}"
      }
      printf("\nFinished in %f seconds.\n", Time.now - @start)
      printf("%d tests, %d assertions, %d failures, %d errors, %d skips\n",
             *numbers)
    end
    private
    def backtrace e
      if $VERBOSE
        e.backtrace
      else
        e.backtrace.reject{ |line| line =~ %r{/pork(/\w+)?\.rb:\d+} }
      end.join("\n  ")
    end
  end
end
