
require 'thread'

module Pork
  Stat = Struct.new(:io, :start, :mutex,
                    :tests, :assertions, :skips, :failures, :errors,
                    :exceptions)

  Stat::Imp = Module.new do
    attr_accessor :stop
    def initialize io=$stdout, st=Time.now, mu=Mutex.new,
                   t=0, a=0, s=0, f=0, e=0, x=[]
      super
    end
    def incr_assertions; mutex.synchronize{ self.assertions += 1 }; end
    def incr_tests     ; mutex.synchronize{ self.tests      += 1 }; end
    def incr_skips     ; mutex.synchronize{ self.skips      += 1 }; end
    def add_failure err
      mutex.synchronize do
        self.failures += 1
        exceptions << err
      end
    end
    def add_error err
      mutex.synchronize do
        self.errors += 1
        exceptions << err
      end
    end
    def case_pass    msg='.'; io.print msg; end
    def case_skip    msg='s'; io.print msg; end
    def case_failed  msg='F'; io.print msg; end
    def case_errored msg='E'; io.print msg; end
    def passed?; exceptions.size == 0                        ; end
    def numbers; [tests, assertions, failures, errors, skips]; end
    def velocity
      time_spent = stop - start
      [time_spent.round(6),
       (tests / time_spent).round(4),
       (assertions / time_spent).round(4)]
    end
    def report
      self.stop = Time.now
      io.puts
      io.puts report_exceptions
      io.printf("\nFinished in %s seconds, %s tests/s, %s assertions/s \n",
                *velocity)
      io.printf("%s tests, %s assertions, %s failures, %s errors, %s skips\n",
                *numbers)
    end
    def merge stat
      self.class.new(io, start, mutex,
        *to_a.drop(3).zip(stat.to_a.drop(3)).map{ |(a, b)| a + b })
    end

    private
    def report_exceptions
      exceptions.reverse_each.map do |(err, msg, source_location)|
        "\n  #{show_command(source_location)}"   \
        "\n  #{show_backtrace(err)}" \
        "\n#{show_message(msg)}"     \
        "\n#{show_exception(err)}"
      end
    end

    def show_command source_location
      "Replicate this test with:\n#{command(source_location)}"
    end

    def command source_location
      "#{env(source_location)} #{Gem.ruby} -S #{$0} #{ARGV.join(' ')}"
    end

    def show_backtrace err
      backtrace(err).join("\n  ")
    end

    def backtrace err
      if $VERBOSE
        err.backtrace
      else
        strip(err.backtrace.reject{ |l| l =~ %r{/lib/pork(/\w+)*\.rb:\d+} })
      end
    end

    def show_message msg
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
      bt.map{ |path| path.sub("#{Dir.pwd}/", '') }
    end

    def env source_location
      "env #{pork(source_location)} #{pork_mode} #{pork_seed}"
    end

    def pork source_location
      file, line = source_location
      "PORK_TEST='#{strip([file]).join}:#{line}'"
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
