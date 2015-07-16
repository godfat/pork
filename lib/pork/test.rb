
require 'pork/auto'

Pork.autorun(false)
Pork.show_source
Pork.Rainbows! if rand(10) == 0

at_exit do
  Pork.module_eval do
    execute_mode(ENV['PORK_MODE'])
    trap
    execute
    %w[sequential shuffled parallel].each do |mode|
      execute_mode(mode)
      execute
    end
    stat.report
    exit stat.failures + stat.errors + ($! && 1).to_i
  end
end
