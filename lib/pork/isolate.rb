
require 'pork'
require 'pork/executor'

module Pork
  module Isolate
    def all_tests
      @all_tests ||= Hash[build_all_tests]
    end

    def isolate name
      executor = Class.new do
        extend Imp
        extend Should if Pork.const_defined?(:Should)
        include Context
        init(name)
      end

      paths, mods, meths = all_tests[name]
      executor.include(*mods)
      # TODO: define instance methods from meths

      _, desc, block = paths[0..-2].inject(tests) do |ts, index|
        ts.first(index).each do |(type, block, _)|
          case type
          when :before
            executor.before(&block)
          when :after
            executor.after(&block)
          end
        end
        ts[index][1].tests
      end[paths.last]

      executor.would(desc, &block)
      executor
    end

    protected
    def build_all_tests paths=[]
      @tests.flat_map.with_index do |(type, arg, _), index|
        case type
        when :describe
          arg.build_all_tests(paths + [index])
        when :would
          [["#{desc.chomp(': ')} #{arg} ##{index} ",
            [paths + [index], included_modules, executor_methods]]]
        else
          []
        end
      end
    end

    def included_modules
      ancestors.drop(1).first(ancestors.index(Pork::Executor)).reject do |a|
        a.kind_of?(Class)
      end
    end

    def executor_methods
      instance_methods(false).map{ |m| instance_method(m) }
    end
  end

  Executor.extend(Isolate)
end
