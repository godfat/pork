
require 'pork/test'

describe 'using fibers to simulate around' do
  def a
    @a ||= []
  end

  def around_me i
    a << "around before #{i}"
    yield
    a << "around after #{i}"
  end

  before do
    a << :before
  end

  after do
    expect(a).eq [:before, "around before 0", :nocall, "around before 1",
      :would, :after, "around after 1", "around after 0"]
  end

  around do |test|
    expect(a).eq [:before]

    around_me(0) do
      test.call

      expect(a).eq [:before, "around before 0", :nocall, "around before 1",
        :would, :after, "around after 1"]
    end
  end

  around do
    expect(a).eq [:before, "around before 0"]

    a << :nocall
  end

  around do |test|
    expect(a).eq [:before, "around before 0", :nocall]

    around_me(1) do
      test.call

      expect(a).eq [:before, "around before 0", :nocall, "around before 1",
        :would, :after]
    end
  end

  after do
    expect(a).eq [:before, "around before 0", :nocall, "around before 1",
      :would]

    a << :after
  end

  would 'wrap around around' do
    expect(a).eq [:before, "around before 0", :nocall, "around before 1"]

    a << :would
  end
end
