
require 'pork'

module Pork
  module Shuffled
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

    def shuffled stat=Stat.new, paths=all_paths
      paths.shuffle.inject(stat, &method(:isolate))
    end

    protected
    def isolate stat, path, super_env=nil
      env = Env.new(super_env)
      idx = path.first

      @tests.first(idx).each do |(type, arg, _)|
        case type
        when :before
          env.before << arg
        when :after
          env.after  << arg
        end
      end

      if path.size == 1
        _, desc, test = @tests[idx]
        run(stat, desc, test, env)
      else
        @tests[idx][1].isolate(stat, path.drop(1), env)
      end

      stat
    end

    def build_all_tests result={}, path=[]
      @tests.each_with_index.inject(result) do |r,
                                                ((type, imp, test, opts),
                                                  index)|
        current = path + [index]

        case type
        when :describe
          imp.build_all_tests(r, current) do |nested|
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

  Executor.extend(Shuffled)
end
