
require 'method_source'

module Pork
  module ShowSource
    def show_source test, err
      source = test.source
      lowers = test.source_location.last
      uppers = lowers + source.size
      lineno = reject_pork(test, err).find do |backtrace|
        l = backtrace[/(?<=\.rb:)\d+/].to_i
        break l if l >= lowers && l < uppers
      end
      lowerl = lineno - lowers
      upperl = MethodSource.expression_at(source, lowerl + 1).
                 count("\n") + lowerl
      indent = source[/^\s*/].size
      result = source.each_line.with_index.map do |source_line, index|
        line = source_line[indent..-1] || "\n"
        if index >= lowerl && index < upperl
          highlight_line("  => #{line}")
        else
          backlight_line("     #{line}")
        end
      end.join
      "\n#{result.chomp}"
    end
  end
end
