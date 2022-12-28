
require 'method_source'

module Pork
  module ShowSource
    module FrozenStringFix
      def extract_first_expression(lines, consume=0, &block)
        code = consume.zero? ? [] : lines.slice!(0..(consume - 1))

        lines.each do |v|
          code << v

          result = block ? block.call(code.join) : code.join

          if complete_expression?(result)
            return result
          end
        end
        raise SyntaxError, "unexpected $end"
      end
    end

    MethodSource.extend(FrozenStringFix)

    def show_source test, err
      source = test.source
      sopath = "#{test.source_location.first}:"
      lowers = test.source_location.last
      uppers = lowers + source.size
      lineno = reject_pork(test, err.backtrace).find do |backtrace|
        # find the line from the test source, exclude everything else
        next unless backtrace.start_with?(sopath)
        number = backtrace[/(?<=\.rb:)\d+/].to_i
        break number if number >= lowers && number < uppers
      end
      return '' unless lineno # TODO: error might be coming from before block
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
    rescue SyntaxError, MethodSource::SourceNotFoundError => e
      "\nPork bug: Cannot parse the source. Please report: #{e}"
    end
  end
end
