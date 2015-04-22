
require 'pork/test'
require 'stringio'

describe Pork::Stat do
  before do
    @executor = Class.new(Pork::Executor){init}
  end

  def run
    @stat = @executor.execute(Pork.execute_mode, Pork::Stat.new(StringIO.new))
    expect_one_error
  end

  def expect_one_error
    expect(@stat.io.string) .eq "\e[31mE\e[0m"
    expect(@stat.tests)     .eq 1
    expect(@stat.assertions).eq 0
    expect(@stat.errors)    .eq 1
  end

  would 'always have backtrace' do
    @executor.would
    run

    err, _, test = @stat.exceptions.first
    err.set_backtrace([])

    expect(@stat.send(:show_backtrace, test, err)).not.empty?
  end

  describe 'Pork::Stat#show_source' do
    def verify source
      run
      err, _, test = @stat.exceptions.first
      yield(err) if block_given?
      expect(@stat.send(:show_source, test, err)).include?(source)
    end

    would 'one line' do
      @executor.would{ flunk }
      verify('=> @executor.would{ flunk }')
    end

    would 'more lines' do
      @executor.would do
        flunk
      end
      verify(<<-SOURCE.chomp)
     @executor.would do
\e[41m  =>   flunk\e[0m
     end
      SOURCE
    end

    would 'multiple lines' do
      @executor.would do
        raise \
          'error'
      end
      verify(<<-SOURCE.chomp)
     @executor.would do
\e[41m  =>   raise \\\e[0m
\e[41m  =>     'error'\e[0m
     end
      SOURCE
    end

    would 'show the line in the test, not other methods' do
      @executor.send(:define_method, :f){ flunk }
      @executor.would do
        f
      end
      verify(<<-SOURCE.chomp)
     @executor.would do
\e[41m  =>   f\e[0m
     end
      SOURCE
    end

    would 'show the line in the test, even if it is from 3rd party' do
      @executor.would{ flunk }
      verify("=> @executor.would{ flunk }") do |err|
        err.set_backtrace(err.backtrace.unshift("bad.rb:#{__LINE__}"))
      end
    end
  end
end
