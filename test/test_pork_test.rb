
require 'pork/test'

describe 'PORK_TEST=a' do
  def verify line, suite, index
    path = Pork::Isolator[suite][index].first
    type, desc, block, opts = extract(path, suite)
    expect(type)                 .eq :would
    expect(desc)                 .eq 'find the corresponding test case'
    expect(block.source_location).eq [__FILE__, line]
    expect(opts)                 .eq :groups => [:a, :b]
  end

  def extract path, suite
    path.inject(suite.tests) do |tests, idx|
      type, arg, = tests[idx]
      case type
      when :describe # we need to go deeper
        arg.tests
      else
        tests[idx] # should end here
      end
    end
  end

  would 'find the corresponding test case', :groups => [:a, :b] do
    line = __LINE__ - 1
    [self.class, Pork::Suite].each do |suite|
      verify(line, suite, "#{__FILE__}:#{__LINE__}") # line
      verify(line, suite, 'a')                       # group
      verify(line, suite, "#{__FILE__}:#{__LINE__}") # diff line
      verify(line, suite, __FILE__)                  # file
      # for self.class, would is the 1st, for Pork::Executor, would is 2nd
    end
  end

  describe 'PORK_TEST=b' do
    would 'find both', :groups => [:b] do
      line = __LINE__ - 1
      top = Pork::Isolator[]
      woulds = top[__FILE__]
      woulds    .size.should.eq 4
      top['a']  .size.should.eq 1
      top['b']  .size.should.eq 2
      top['b']       .should.eq woulds.first(2)
      top['a,b']     .should.eq woulds.first(2)
      local = Pork::Isolator[self.class]
      local['a']     .should.nil?
      local['b'].size.should.eq 1

      a, b = top['b'].map{ |path| extract(path, Pork::Suite) }
      expect(a[0])                .eq :would
      expect(a[1])                .eq 'find the corresponding test case'
      expect(a[3])                .eq :groups => [:a, :b]
      expect(b[0])                .eq :would
      expect(b[1])                .eq 'find both'
      expect(b[2].source_location).eq [__FILE__, line]
      expect(b[3])                .eq :groups => [:b]
    end
  end

  describe 'PORK_TEST=c', :groups => [:c] do
    would 'inherit groups from describe', :groups => [:d] do
      line = __LINE__ - 2
      isolator = Pork::Isolator[]
      c = isolator['c']
      d = isolator['d']
      expect(c.size)                         .eq 2
      expect(d.size)                         .eq 1
      expect(c.first)                        .eq d.first
      expect(isolator["#{__FILE__}:#{line}"]).eq c
    end

    would 'dummy' do
      ok
    end
  end
end
