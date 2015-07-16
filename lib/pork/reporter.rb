
module Pork
  Reporter = Struct.new(:io)

  module Reporter::Imp
    def initialize o=$stdout
      super
      Pork.reporter_extensions.each(&method(:extend))
    end

    def case_pass   ; io.print msg_pass   ; end
    def case_skip   ; io.print msg_skip   ; end
    def case_failed ; io.print msg_failed ; end
    def case_errored; io.print msg_errored; end

    def report stat
      io.puts
      io.puts messages(stat)
      io.printf("\nFinished in %s seconds, %s tests/s, %s assertions/s \n",
                *velocity(stat))
      io.printf("%s tests, %s assertions, %s failures, %s errors, %s skips\n",
                *numbers(stat))
    end

    private
    def velocity stat
      stat.velocity
    end

    def numbers stat
      stat.numbers
    end

    def messages stat
      stat.exceptions.reverse_each.map do |(err, msg, test)|
        "\n  #{show_command(test.source_location)}" \
        "\n  #{show_backtrace(test, err)}"          \
        "#{show_source(test, err)}"                 \
        "\n#{show_message(msg)}"                    \
        "\n#{show_exception(err)}"
      end
    end

    def show_command source_location
      "Replicate this test with:\n#{command(source_location)}"
    end

    def command source_location
      "#{env(source_location)} #{Gem.ruby} -S #{$0} #{ARGV.join(' ')}"
    end

    def show_backtrace test, err
      backtrace(test, err).join("\n  ")
    end

    def backtrace test, err
      if $VERBOSE
        err.backtrace
      else
        strip(reject_pork(test, err))
      end
    end

    def show_source _, _
      ''
    end

    def highlight_line line
      line
    end

    def backlight_line line
      line
    end

    def show_message msg
      msg
    end

    def show_exception err
      "#{err.class}: #{err.message}"
    end

    def reject_pork test, err
      bt = err.backtrace.reject{ |l| l =~ %r{/lib/pork(/\w+)*\.rb:\d+} }
      if bt.empty?
        ["#{test.source_location.join(':')}:in `block in would'"]
      else
        bt
      end
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

  Reporter.__send__(:include, Reporter::Imp)
end
