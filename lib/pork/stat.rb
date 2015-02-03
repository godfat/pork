
require 'pork/more/bottomup_backtrace'
require 'pork/more/color'

require 'thread'

module Pork
  Stat = Struct.new(:io, :start, :mutex,
                    :tests, :assertions, :skips, :failures, :errors,
                    :exceptions)

  Stat::Imp = Module.new do
    def initialize io=$stdout, st=Time.now, mu=Mutex.new,
                   t=0, a=0, s=0, f=0, e=0, x=[]
      super
    end
    def incr_assertions; mutex.synchronize{ self.assertions += 1 }; end
    def incr_tests     ; mutex.synchronize{ self.tests      += 1 }; end
    def incr_skips     ; mutex.synchronize{ self.skips      += 1 }; end
    def add_failure *err
      mutex.synchronize do
        self.failures += 1
        exceptions << err
      end
    end
    def add_error *err
      mutex.synchronize do
        self.errors += 1
        exceptions << err
      end
    end
    def passed?; exceptions.size == 0                        ; end
    def numbers; [tests, assertions, failures, errors, skips]; end
    def report
      io.puts
      io.puts report_exceptions
      io.printf("\nFinished in %f seconds.\n", Time.now - start)
      io.printf("%d tests, %d assertions, %d failures, %d errors, %d skips\n",
                *numbers)
    end
    def merge stat
      self.class.new(io, start, nil,
        *to_a.drop(3).zip(stat.to_a.drop(3)).map{ |(a, b)| a + b })
    end

    private
    def report_exceptions
      exceptions.reverse.map do |(err, msg)|
        "\n  #{show_command(msg)}"   \
        "\n  #{show_backtrace(err)}" \
        "\n#{message(msg)}"          \
        "\n#{show_exception(err)}"
      end
    end

    def show_command name
      "Replicate this test with:\n#{command(name)}"
    end

    def command name
      "#{env(name)} #{Gem.ruby} -S #{$0} #{ARGV.join(' ')}"
    end

    def show_backtrace err
      backtrace(err).join("\n  ")
    end

    def backtrace err
      if $VERBOSE
        err.backtrace
      else
        strip(err.backtrace.reject{ |line| line =~ %r{/pork(/\w+)?\.rb:\d+} })
      end
    end

    def message msg
      msg
    end

    def show_exception err
      "#{err.class}: #{err.message}"
    end

    def strip bt
      strip_home(strip_cwd(bt))
    end

    def strip_home bt
      bt.map{ |path| path.sub(ENV['HOME'], '~') }
    end

    def strip_cwd bt
      bt.map{ |path| path.sub(Dir.pwd, '.') }
    end

    def env name
      "env #{pork(name)} #{pork_mode} #{pork_seed}"
    end

    def pork name
      "PORK_TEST='#{name.gsub("'", "\\\\'")}'"
    end

    def pork_mode
      "PORK_MODE=#{Pork.execute_mode}"
    end

    def pork_seed
      "PORK_SEED=#{Pork.seed}"
    end
  end

  Stat.__send__(:include, Stat::Imp)
end
