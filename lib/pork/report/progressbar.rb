
require 'ruby-progressbar'

require 'pork/report'

module Pork
  class Progressbar < Report
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

    class Bar < ::ProgressBar::Base
      attr_accessor :thread

      def initialize reporter, *args
        super(*args)

        # don't print extra newline
        output.extend(CarriageReturn)

        # colourize the bar
        @format.molecules.each do |m|
          m.extend(Painter)
          m.reporter = reporter
        end

        # set FPS to 30
        self.thread = Thread.new do
          until finished?
            sleep(0.033)
            update_progress(:itself)
          end
        end
      end

      def tick
        progressable.increment
        thread.join if finished?
      end

      def raise size
        progressable.total += size
      end
    end

    def prepare paths
      if bar
        bar.raise(paths.size)
      else
        self.bar = Bar.new(self, :output => io, :total => paths.size,
                                 :format => format)
      end
    end

    def case_skip   ; end
    def case_failed ; self.failed = true; end
    def case_errored; self.failed = true; end

    def case_pass
      bar.tick
    end

    def paint text
      text
    end

    private
    def format
      "   %c/%C (#{time('%P%')}) |%b>%i| #{time('%e')} "
    end
  end
end
