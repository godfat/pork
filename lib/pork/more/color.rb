
require 'pork'

module Pork
  module Color
    def msg_skip   ;  yellow(super); end
    def msg_failed ; magenta(super); end
    def msg_errored;     red(super); end

    private
    def command name
      gray(super)
    end

    def show_message msg
      blue(super)
    end

    def show_exception err
      magenta(super)
    end

    def highlight_line line
      "#{color(41, super.chomp)}\n"
    end

    def time_spent
      cyan(super)
    end

    def numbers stat
      stat.numbers.zip(%w[green green magenta red yellow]).map do |(num, col)|
        if num == 0
          num
        else
          send(col, num)
        end
      end
    end

    def velocity stat
      stat.velocity.zip(%w[cyan blue blue]).map do |(str, col)|
        send(col, str)
      end
    end

    def backtrace *_
      super.map do |b|
        path, msgs = b.split(':', 2)
        dir , file = ::File.split(path)
        msg = msgs.sub(/(\d+):/){red($1)+':'}.sub(/`.+?'/){green($&)}

        "#{dir+'/'}#{yellow(file)}:#{msg}"
      end
    end

    def    gray text; color('1;30', text); end
    def   black text; color(   30 , text); end
    def     red text; color(   31 , text); end
    def   green text; color(   32 , text); end
    def  yellow text; color(   33 , text); end
    def    blue text; color(   34 , text); end
    def magenta text; color(   35 , text); end
    def    cyan text; color(   36 , text); end
    def   white text; color(   37 , text); end

    def color rgb, text
      "\e[#{rgb}m#{text}\e[0m"
    end
  end

  reporter_extensions << Color
end
