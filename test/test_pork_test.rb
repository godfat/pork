
require 'pork/test'

describe 'PORK_TEST=a' do
  def verify line, executor, index, offset=0
    path = executor[index][offset]
    type, desc, block, opts = extract(path, executor)
    expect(type)                 .eq :would
    expect(desc)                 .eq 'find the corresponding test case'
    expect(block.source_location).eq [__FILE__, line]
    expect(opts)                 .eq :groups => [:a, :b]
  end

  def extract path, executor
    path.inject(executor.instance_variable_get(:@tests)) do |tests, idx|
      type, arg, = tests[idx]
      case type
      when :describe # we need to go deeper
        arg.instance_variable_get(:@tests)
      else
        tests[idx] # should end here
      end
    end
  end

  def woulds
    @woulds ||= Pork::Executor[__FILE__].select{ |p| p.kind_of?(Array) }
  end

  would 'find the corresponding test case', :groups => [:a, :b] do
    line = __LINE__ - 1
    [self.class, Pork::Executor].each.with_index do |executor, index|
      verify(line, executor, "#{__FILE__}:#{__LINE__}") # line
      verify(line, executor, 'a')                       # group
      verify(line, executor, "#{__FILE__}:#{__LINE__}") # diff line
      verify(line, executor, __FILE__, index)           # file
      # for self.class, would is the 1st, for Pork::Executor, would is 2nd
    end
  end

  describe 'PORK_TEST=b' do
    would 'find both', :groups => [:b] do
      line = __LINE__ - 1
      Pork::Executor[__FILE__].size.should.eq 6 # 3 describe
      woulds                  .size.should.eq 3
      Pork::Executor['a']     .size.should.eq 1
      Pork::Executor['b']     .size.should.eq 2
      Pork::Executor['b']          .should.eq woulds.first(2)
      Pork::Executor['a,b']        .should.eq woulds.first(2)
      self.class['a']              .should.nil?
      self.class['b']         .size.should.eq 1

      a, b = Pork::Executor['b'].map{ |path| extract(path, Pork::Executor) }
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
      c = Pork::Executor['c']
      expect(c.size )                              .eq 1
      expect(c.first)                              .eq self.class
      expect(Pork::Executor["#{__FILE__}:#{line}"]).eq [self.class]
    end
  end
end
