
require 'pork/auto'

Pork.autorun(false)

at_exit do
  Pork.module_eval do
    execute_mode(ENV['PORK_MODE'])
    trap
    run
    %i[sequential shuffled parallel].each do |mode|
      execute_mode(mode)
      run
    end
    stat.report
    exit stat.failures + stat.errors + ($! && 1).to_i
  end
end
