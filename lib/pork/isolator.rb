
require 'pork/env'
require 'pork/executor'

module Pork
  class Isolator < Struct.new(:executor)
    def self.[] executor=Executor
      @map ||= {}
      @map[executor] ||= new(executor)
    end

    def execute mode=Pork.execute_mode, *args
      require "pork/mode/#{mode}"
      mod = Pork.const_get(mode.to_s.capitalize)
      mod.extend(Should)
      mod.execute(self, *args)
    end

    def all_tests
      @all_tests ||= build_all_tests
    end

    def all_paths
      (all_tests[:files] || {}).values.flat_map(&:values).flatten(1).uniq
    end

    def [] index
      by_groups(index) || by_source(index)
    end

    def by_groups groups
      return unless tests = all_tests[:groups]
      paths = groups.split(',').flat_map do |g|
        tests[g.strip] || []
      end.uniq
      paths unless paths.empty?
    end

    def by_source source
      return unless tests = all_tests[:files]
      file_str, line_str = source.split(':')
      file, line = File.expand_path(file_str), line_str.to_i
      return unless cases = tests[file]
      if line.zero?
        cases.values.flatten(1).uniq
      else
        _, paths = cases.reverse_each.find{ |(l, _)| l <= line }
        paths
      end
    end

    protected
    def isolate stat, path, super_env=nil
      env = Env.new(super_env)
      idx = path.first

      executor.tests.first(idx).each do |(type, arg, _)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        end
      end

      if path.size == 1
        _, desc, test = executor.tests[idx]
        executor.run(stat, desc, test, env)
      else
        Isolator[executor.tests[idx][1]].isolate(stat, path.drop(1), env)
      end

      stat
    end

    def build_all_tests result={}, path=[]
      executor.tests.each_with_index.inject(result) do |
        r, ((type, imp, test, opts), index)|
        current = path + [index]

        case type
        when :describe
          Isolator[imp].build_all_tests(r, current) do |nested|
            store_path(r, nested, test, opts[:groups])
          end
        when :would
          yield(current) if block_given?
          store_path(r, current, test, opts[:groups])
        end

        r
      end
    end

    def store_path tests, path, test, groups
      store_for_groups(tests, path, groups) if groups
      store_for_source(tests, path, *test.source_location)
    end

    def store_for_groups tests, path, groups
      r = tests[:groups] ||= {}
      groups.each do |g|
        (r[g.to_s] ||= []) << path
      end
    end

    def store_for_source tests, path, file, line
      r = tests[:files] ||= {}
      ((r[File.expand_path(file)] ||= {})[line] ||= []) << path
    end
  end
end
