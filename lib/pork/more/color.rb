
require 'pork/stat'

module Pork
  module Color
    def case_skip    msg='s'; super(yellow {msg}); end
    def case_failed  msg='F'; super(magenta{msg}); end
    def case_errored msg='E'; super(red    {msg}); end

    private
    def command name
      gray{super}
    end

    def message msg
      blue{super}
    end

    def show_exception err
      magenta{super}
    end

    def time_spent
      cyan{super}
    end

    def numbers
      super.zip(%w[green green magenta red yellow]).map do |(num, col)|
        if num == 0
          num
        else
          send(col){ num }
        end
      end
    end

    def backtrace err
      super.map do |b|
        path, msgs = b.split(':', 2)
        dir , file = ::File.split(path)
        msg = msgs.sub(/(\d+):/){red{$1}+':'}.sub(/`.+?'/){green{$&}}

        "#{dir+'/'}#{yellow{file}}:#{msg}"
      end
    end

    def    gray &block; color('1;30', &block); end
    def   black &block; color(   30 , &block); end
    def     red &block; color(   31 , &block); end
    def   green &block; color(   32 , &block); end
    def  yellow &block; color(   33 , &block); end
    def    blue &block; color(   34 , &block); end
    def magenta &block; color(   35 , &block); end
    def    cyan &block; color(   36 , &block); end
    def   white &block; color(   37 , &block); end

    def color rgb
      "\e[#{rgb}m#{yield}\e[0m"
    end
  end

  Pork::Stat.__send__(:include, Pork::Color)
end
