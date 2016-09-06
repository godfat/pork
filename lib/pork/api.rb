
require 'pork/executor'

module Pork
  module API
    module_function
    def before &block
      Executor.before(&block)
    end

    def after &block
      Executor.after(&block)
    end

    def copy desc=:default, &block
      Executor.copy(desc, &block)
    end

    def paste desc=:default, *args
      Executor.paste(desc, *args)
    end

    def describe desc=:default, opts={}, &suite
      Executor.describe(desc, opts, &suite)
    end

    def would desc=:default, opts={}, &test
      Executor.would(desc, opts, &test)
    end
  end
end
