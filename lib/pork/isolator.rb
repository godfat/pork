
require 'pork/env'
require 'pork/suite'

module Pork
  class Isolator < Struct.new(:suite)
    def self.[] suite=Suite
      @map ||= {}
      @map[suite] ||= new(suite)
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

      suite.tests.first(idx).each do |(type, arg, _)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        end
      end

      if path.size == 1
        _, desc, test = suite.tests[idx]
        suite.run(stat, desc, test, env)
      else
        Isolator[suite.tests[idx][1]].isolate(stat, path.drop(1), env)
      end

      stat
    end

    def build_all_tests result={}, path=[]
      suite.tests.each_with_index.inject(result) do |
        tests, ((type, imp, block, opts), index)|
        current = path + [index]

        case type
        when :describe, :would
          source_location = expand_source_location(block)
          init_source_store_path(tests, source_location)
        end

        case type
        when :describe
          Isolator[imp].build_all_tests(tests, current) do |nested|
            store_path(tests, nested, source_location, opts[:groups])
          end
        when :would
          yield(current) if block_given?
          store_path(tests, current, source_location, opts[:groups])
        end

        tests
      end
    end

    def expand_source_location block
      file, line = block.source_location
      [File.expand_path(file), line]
    end

    def init_source_store_path tests, source_location
      source, line = source_location

      root = tests[:files] ||= {}
      map = root[source] ||= {}

      # Most of the time, line is always getting larger because we're
      # scanning from top to bottom, and we really need to make sure
      # that the map is sorted because whenever we're looking up which
      # test we want from a particular line, we want to find the closest
      # block rounding up. See Isolator#by_source
      # However, it's not always appending from top to bottom, because
      # we might be adding more tests from Suite#paste, and the original
      # test could be defined in the same file, on previous lines!
      # Because of this, we really need to make sure the map is balanced.
      # If we ever have ordered map in Ruby, we don't have to do this...
      # See the test for Isolator.all_tests (test/test_isolator.rb)
      balanced_append(map, line, [])
    end

    def store_path tests, path, source_location, groups
      store_for_groups(tests, path, groups) if groups
      store_for_source(tests, path, source_location)
    end

    def store_for_groups tests, path, groups
      map = tests[:groups] ||= {}
      groups.each do |g|
        (map[g.to_s] ||= []) << path
      end
    end

    def store_for_source tests, path, source_location
      source, line = source_location

      tests[:files][source][line] << path
    end

    def balanced_append map, key, value
      last_key = map.reverse_each.first.first unless map.empty?

      map[key] ||= []

      map.replace(Hash[map.sort]) if last_key && key < last_key
    end
  end
end
