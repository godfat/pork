
require 'thread'

module Pork
  class Stat < Struct.new(:io, :start, :mutex,
                          :tests, :assertions, :skips, :failures, :errors,
                          :exceptions)
    def initialize io=$stdout, st=Time.now, mu=Mutex.new,
                   t=0, a=0, s=0, f=0, e=0, x=[]
      super
    end
    def incr_assertions; mutex.synchronize{ self.assertions += 1 }; end
    def incr_tests     ; mutex.synchronize{ self.tests      += 1 }; end
    def incr_skips     ; mutex.synchronize{ self.skips      += 1 }; end
    def add_failure *e
      mutex.synchronize do
        self.failures += 1
        exceptions << e
      end
    end
    def add_error *e
      mutex.synchronize do
        self.errors += 1
        exceptions << e
      end
    end
    def passed?; exceptions.size == 0                        ; end
    def numbers; [tests, assertions, failures, errors, skips]; end
    def report
      io.puts
      io.puts exceptions.map{ |(e, m)|
        "\n#{m}\n#{e.class}: #{e.message}\n  #{backtrace(e)}\n#{command(m)}"
      }
      io.printf("\nFinished in %f seconds.\n", Time.now - start)
      io.printf("%d tests, %d assertions, %d failures, %d errors, %d skips\n",
                *numbers)
    end
    def merge stat
      self.class.new(io, start, nil,
        *to_a.drop(3).zip(stat.to_a.drop(3)).map{ |(a, b)| a + b })
    end

    private
    def backtrace e
      if $VERBOSE
        e.backtrace
      else
        strip(e.backtrace.reject{ |line| line =~ %r{/pork(/\w+)?\.rb:\d+} })
      end.join("\n  ")
    end

    def strip backtrace
      strip_home(strip_cwd(backtrace))
    end

    def strip_home backtrace
      backtrace.map{ |path| path.sub(ENV['HOME'], '~') }
    end

    def strip_cwd backtrace
      backtrace.map{ |path| path.sub(Dir.pwd, '.') }
    end

    def command name
      "You can replicate this test with the following command:\n  " \
      "#{env(name)} #{Gem.ruby} -S #{$0} #{ARGV.join(' ')}"
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
end
