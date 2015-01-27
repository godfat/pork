
require 'pork/executor'

module Pork
  module API
    module_function
    def before &block; Executor.before(&block); end
    def after  &block; Executor.after( &block); end
    def copy     desc=:default, &block; Executor.copy(    desc, &block); end
    def paste    desc=:default, *args ; Executor.paste(   desc, *args ); end
    def describe desc=:default, &suite; Executor.describe(desc, &suite); end
    def would    desc=:default, &test ; Executor.would(   desc, &test ); end
  end

  # default to :execute while eliminating warnings for uninitialized ivar
  def self.execute_mode execute=nil
    @execute = execute || @execute ||= :execute
  end

  def self.stat
    @stat ||= Pork::Stat.new
  end

  def self.seed
    @seed ||= if Random.const_defined?(:DEFAULT)
                Random::DEFAULT.seed
              else
                Thread.current.randomizer.seed # Rubinius (rbx)
              end
  end

  def self.trap sig='SIGINT'
    Signal.trap(sig) do
      stat.report
      puts "\nterminated by signal SIGINT"
      exit! 255
    end
  end

  def self.run
    if ENV['PORK_TEST']
      require 'pork/isolate'
      if paths = Executor.all_tests[ENV['PORK_TEST']]
        case execute_mode
        when :execute
          paths.each{ |p| Executor.isolate(p, stat) }
        else
          @stat = Executor.public_send(execute_mode, stat, paths)
        end
      else
        puts "Cannot find test: #{ENV['PORK_TEST']}"
        exit! 254
      end
    else
      @stat = Executor.public_send(execute_mode, stat)
    end
  end

  def self.autorun auto=true
    @auto = auto
    @autorun ||= at_exit do
      next unless @auto
      Random.srand(ENV['PORK_SEED'].to_i) if ENV['PORK_SEED']
      execute_mode(ENV['PORK_MODE'])      if ENV['PORK_MODE']
      require "pork/mode/#{execute_mode}" unless execute_mode == :execute
      seed
      trap
      run
      stat.report
      exit! stat.failures.size + stat.errors.size + ($! && 1).to_i
    end
  end
end
