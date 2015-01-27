
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

  def self.autorun auto=true
    @auto = auto
    @autorun ||= at_exit do
      next unless @auto
      require "pork/mode/#{execute_mode}" unless execute_mode == :execute
      stat = Pork::Stat.new

      Signal.trap('SIGINT') do
        stat.report
        puts "\nterminated by signal SIGINT"
        exit 1
      end

      Executor.public_send(execute_mode, stat)
      stat.report
      exit stat.failures.size + stat.errors.size + ($! && 1).to_i
    end
  end
end
