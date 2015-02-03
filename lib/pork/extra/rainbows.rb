
module Pork
  module Rainbows
    def case_pass msg='.'
      @rainbows ||= 0
      io.print( color256(rainbows(@rainbows)){msg} )
      @rainbows  += 1
    end

    private
    def color256 rgb
      "\e[38;5;#{rgb}m#{yield}\e[0m"
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
