
module Pork
  module Color
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
    def   reset &block; color(    0 , &block); end

    def color rgb
      "\e[#{rgb}m" + if block_given? then "#{yield}#{reset}" else '' end
    end
  end
end
