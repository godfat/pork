
require 'pork/executor'

module Pork
  Error   = Class.new(StandardError)
  Failure = Class.new(Error)
  Skip    = Class.new(Error)

  module API
    module_function
    def before &block; Executor.before(&block); end
    def after  &block; Executor.after( &block); end
    def describe desc=:default, &suite; Executor.describe(desc, &suite); end
    def copy     desc=:default, &suite; Executor.copy(    desc, &suite); end
    def paste    desc=:default, *args ; Executor.paste(   desc, *args ); end
    def would    desc=:default, &test ; Executor.would(   desc, &test ); end
    def expect *args, &block; Expect.new(Executor, *args, &block); end
  end

  def self.autorun auto=true
    @auto = auto
    @autorun ||= at_exit do
      next unless @auto
      Executor.execute
      Executor.stat.report
      exit Executor.stat.failures.size +
           Executor.stat.errors.size + ($! && 1).to_i
    end
  end
end
