
require 'thread'

module Pork
  class Stat < Struct.new(:tests, :assertions, :skips,
                          :failures, :errors, :start, :io)
    def initialize io=$stdout
      @mutex = Mutex.new
      super(0, 0, 0, [], [], Time.now, io)
    end

    def incr_assertions; @mutex.synchronize{ self.assertions += 1 }; end
    def incr_tests     ; @mutex.synchronize{ self.tests      += 1 }; end
    def incr_skips     ; @mutex.synchronize{ self.skips      += 1 }; end
    def add_failure *e ; @mutex.synchronize{ failures        << e }; end
    def add_error   *e ; @mutex.synchronize{ errors          << e }; end
    def passed?; failures.size + errors.size == 0                      ; end
    def numbers; [tests, assertions, failures.size, errors.size, skips]; end
    def report
      io.puts
      io.puts (failures + errors).map{ |(e, m)|
        "\n#{m}\n#{e.class}: #{e.message}\n  #{backtrace(e)}"
      }
      io.printf("\nFinished in %f seconds.\n", Time.now - start)
      io.printf("%d tests, %d assertions, %d failures, %d errors, %d skips\n",
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
