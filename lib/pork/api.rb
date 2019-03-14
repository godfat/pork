
require 'pork/suite'

module Pork
  module API
    module_function
    def before &block
      Suite.before(&block)
    end

    def after &block
      Suite.after(&block)
    end

    def around &block
      Suite.around(&block)
    end

    def copy desc=:default, &block
      Suite.copy(desc, &block)
    end

    def paste desc=:default, *args
      Suite.paste(desc, *args)
    end

    def describe desc=:default, opts={}, &suite
      Suite.describe(desc, opts, &suite)
    end

    def would desc=:default, opts={}, &test
      Suite.would(desc, opts, &test)
    end
  end
end
