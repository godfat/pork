
module Pork
  module Rainbows
    def msg_pass
      @rainbows ||= -1
      @rainbows  += +1
      color256(rainbows(@rainbows), strip_color(super))
    end

    def paint text
      @demping ||= -1
      @demping  += +1
      @rainbows = @demping
      strip_color(text).each_char.map do |c|
        @rainbows += +1
        color256(rainbows(@rainbows), c)
      end.join
    end

    private
    def strip_color text
      text.gsub(/\e\[\d+m/, '')
    end

    def color256 rgb, text
      "\e[38;5;#{rgb}m#{text}\e[0m"
    end

    def rainbows i
      n = (i%42) / 6.0
      r = Math.sin(n + 0*Math::PI/3) * 3 + 3
      g = Math.sin(n + 2*Math::PI/3) * 3 + 3
      b = Math.sin(n + 4*Math::PI/3) * 3 + 3
      16 + 36*r.to_i + 6*g.to_i + b.to_i
    end
  end
end
