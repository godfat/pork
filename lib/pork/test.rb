
require 'pork/auto'

Pork.autorun(false)
Pork.show_source

at_exit do
  Pork.module_eval do
    execute_mode(ENV['PORK_MODE'])
    trap
    run
    %w[sequential shuffled parallel].each do |mode|
      execute_mode(mode)
      run
    end
    stat.report
    exit stat.failures + stat.errors + ($! && 1).to_i
  end
end
