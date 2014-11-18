
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

  def self.autorun auto=true
    @auto = auto
    @autorun ||= at_exit do
      next unless @auto
      stat = Executor.execute
      stat.report
      exit stat.failures.size + stat.errors.size + ($! && 1).to_i
    end
  end
end
