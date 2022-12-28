
require 'pork/api'
require 'pork/stat'
require 'pork/executor'

module Pork
  # default to :shuffled while eliminating warnings for uninitialized ivar
  def self.execute_mode mode=nil
    @execute_mode = mode || @execute_mode ||= :shuffled
  end

  def self.report_mode mode=nil
    @report_mode = mode || @report_mode ||= :dot
    require "pork/report/#{@report_mode}"
    @report_mode
  end

  def self.report_class
    const_get(report_mode.to_s.capitalize)
  end

  def self.report_extensions
    @report_extensions ||= []
  end

  def self.execute_extensions
    @execute_extensions ||= []
  end

  def self.protected_exceptions
    @protected_exceptions ||= [Pork::Error, StandardError]
  end

  def self.Rainbows!
    require 'pork/extra/rainbows'
    report_extensions << Rainbows
  end

  def self.show_source
    require 'pork/extra/show_source'
    report_extensions << ShowSource
  end

  def self.stat
    @stat ||= Pork::Stat.new
  end

  def self.seed
    @seed ||= Random.seed
  end

  def self.reseed
    if ENV['PORK_SEED']
      seed
    else
      new_seed = Random.new_seed
      Random.srand(new_seed)
      new_seed
    end
  end

  def self.srand
    case ENV['PORK_SEED']
    when nil, 'random'
      Random.srand(seed)
    else
      Random.srand(Integer(ENV['PORK_SEED']))
    end
  end

  def self.trap sig='SIGINT'
    Signal.trap(sig) do
      stat.report
      puts "\nterminated by signal #{sig}"
      exit 255
    end
  end

  def self.execute
    if ENV['PORK_TEST']
      if tests = Executor[ENV['PORK_TEST']]
        @stat = Executor.execute(:paths => tests)
      else
        puts "Cannot find test: #{ENV['PORK_TEST']}"
        exit 254
      end
    else
      @stat = Executor.execute
    end
  end

  def self.run
    srand
    execute_mode(ENV['PORK_MODE'])
    report_mode(ENV['PORK_REPORT'])
    trap
    stat.loaded(@at, @files) if instance_variable_defined?(:@at)
    execute
    stat.report
  end

  def self.loaded at=Time.now
    @at = at
    @files = $LOADED_FEATURES.size
  end

  def self.autorun auto=true
    @auto = auto
    @autorun ||= at_exit do
      next unless @auto
      run
      exit stat.failures + stat.errors + ($! && 1).to_i
    end
  end
end
