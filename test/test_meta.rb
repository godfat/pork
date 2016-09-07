
require 'pork/test'

describe 'meta' do
  before do
    @stat = Pork::Stat.new(Pork.report_class.new(StringIO.new))
    @suite = Class.new(Pork::Suite){init}
  end

  def execute
    Pork::Executor.execute(:suite => @suite, :stat => @stat)
  end

  would 'raise missing assertion' do
    @suite.would{}
    @suite.after{ok} # defined after would so no run for that
    stat = execute
    err, _, _ = stat.exceptions.first

    expect(err).kind_of?(Pork::Error)
    expect(err.message).eq 'Missing assertions'
  end

  would 'not raise missing assertion if there is one in after block' do
    @suite.after{ok}
    @suite.would{}
    stat = execute

    expect(stat.exceptions).empty?
  end

  would 'run after block even if there is an error in test' do
    called = false
    @suite.after{ called = true }
    @suite.would{ flunk }
    execute

    expect(called).eq true
  end
end
