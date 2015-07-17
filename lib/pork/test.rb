
require 'pork/auto'

Pork.autorun
Pork.show_source
Pork.Rainbows! if rand(10) == 0

Pork.singleton_class.prepend Module.new{
  def execute
    super
    %w[sequential shuffled parallel].each do |mode|
      execute_mode(mode)
      super
    end
  end
}
