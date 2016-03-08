
require 'ruby-progressbar'

require 'pork/isolate'
require 'pork/report'

module Pork
  class Progress < Report
    attr_accessor :bar, :failed

    module CarriageReturn
      def eol; "\r"; end
    end

    module Painter
      attr_accessor :reporter

      def lookup_value *args
        case key
        when 'b'
          reporter.paint(super)
        when 'C'
          reporter.send(:ok, super)
        when 'c'
          if reporter.failed
            reporter.send(:bad, super)
          else
            reporter.send(:ok, super)
          end
        else
          super
        end
      end
    end

    class Bar < ProgressBar::Base
      def initialize reporter, *args
        super(*args)
        output.extend(CarriageReturn)
        @format.molecules.each do |m|
          m.extend(Painter)
          m.reporter = reporter
        end
      end
    end

    def prepare paths
      if bar
        bar.total += paths.size
      else
        self.bar = Bar.new(self, :output => io, :total => paths.size,
                                 :format => format)
      end
    end

    def paint   text; text         ; end
    def case_pass   ; bar.increment; end
    def case_skip   ;                end
    def case_failed ; self.failed = true; end
    def case_errored; self.failed = true; end

    private
    def format
      "   %c/%C (#{time('%P%')}) |%b>%i| #{time('%e')} "
    end
  end
end
