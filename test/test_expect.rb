
require 'pork/test'

describe Pork::Expect do
  would 'eq' do
    expect(1).eq 1
  end

  would 'lt' do
    expect(0).lt 1
  end

  would 'gt' do
    expect(1).gt 0
  end

  would 'lte' do
    expect(0).lte 0
    expect(0).lte 1
  end

  would 'gte' do
    expect(1).gte 1
    expect(1).gte 0
  end

  would 'approx' do
    expect(1.2345678901234).approx 1.2345678901
    expect(1.2345678901234).approx 1.23456789012
    expect(1.2345678901234).approx 1.234567890123
    expect(1.2345678901234).approx 1.234567890124
    expect(1.23).approx 1.23  , 2
    expect(1.23).approx 1.225 , 2
    expect(1.23).approx 1.234 , 2
    expect(1.23).approx 1.2345, 2
  end
end
