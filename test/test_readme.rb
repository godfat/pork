
require 'pork/test'

describe 'README.md' do
  File.read("#{File.dirname(File.expand_path(__FILE__))}/../README.md").
    scan(%r{``` ruby\nrequire 'pork/auto'\n(.+?)\n```}m).
    each.with_index do |(code), index|
      would 'pass from README.md #%02d' % index do
        suite = Class.new(Pork::Suite) do
          init
          instance_eval(code)
        end

        Pork::Executor.execute(:suite => suite)
        ok
      end
  end
end
