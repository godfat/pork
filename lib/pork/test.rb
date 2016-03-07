
require 'pork/auto'

Pork.show_source
Pork.Rainbows! if rand(10) == 0

WebMockError = Class.new(Exception)
Pork.protected_exceptions << WebMockError

Pork.singleton_class.send(:prepend, Module.new{
  def execute
    super
    %w[sequential shuffled parallel].each do |mode|
      execute_mode(mode)
      super
    end
  end
})
