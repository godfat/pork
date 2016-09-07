
describe 'meta' do
  before do
    @stat = Pork::Stat.new(Pork.report_class.new(StringIO.new))
    @executor = Class.new(Pork::Executor){init}
  end

  def execute
    @executor.execute(Pork.execute_mode, @stat)
  end

  would 'raise missing assertion' do
    @executor.would{}
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
end
