
require 'pork/test'

describe Pork::Should do
  def check_group_list level=9
    Thread.new{ check_group_list(level - 1) }.join if level > 0
    ok
  end

  would '#should' do
    asserts = pork_stat.assertions
    check_group_list
    (pork_stat.assertions - asserts).should.eq 10
  end
end
