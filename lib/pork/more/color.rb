
require 'pork/stat'

module Pork
  module Color
    def case_skip    msg='s'; super(yellow( msg)); end
    def case_failed  msg='F'; super(magenta(msg)); end
    def case_errored msg='E'; super(red(    msg)); end

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

    def time_spent
      cyan(super)
    end

    def numbers
      super.zip(%w[green green magenta red yellow]).map do |(num, col)|
        if num == 0
          num
        else
          send(col, num)
        end
      end
    end

    def velocity
      super.zip(%w[cyan blue blue]).map do |(str, col)|
        send(col, str)
      end
    end

    def backtrace err
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

  Pork::Stat.__send__(:include, Pork::Color)
end
