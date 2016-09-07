
require 'pork/test'

describe 'meta' do
  before do
    @stat = Pork::Stat.new(Pork.report_class.new(StringIO.new))
    @executor = Class.new(Pork::Executor){init}
  end

  def execute
    Pork::Isolator[@executor].execute(Pork.execute_mode, @stat)
  end

  would 'raise missing assertion' do
    @executor.would{}
    @executor.after{ok} # defined after would so no run for that
    stat = execute
    err, _, _ = stat.exceptions.first

    expect(err).kind_of?(Pork::Error)
    expect(err.message).eq 'Missing assertions'
  end

  would 'not raise missing assertion if there is one in after block' do
    @executor.after{ok}
    @executor.would{}
    stat = execute

    expect(stat.exceptions).empty?
  end

  would 'run after block even if there is an error in test' do
    called = false
    @executor.after{ called = true }
    @executor.would{ flunk }
    execute

    expect(called).eq true
  end
end
