
require 'pork'

module Pork
  module Shuffled
    def all_tests
      @all_tests ||= build_all_tests
    end

    def all_paths
      (all_tests[:files] || {}).values.flat_map(&:values).flatten(1).
        select{ |path| path.kind_of?(Array) }
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
        cases.values.flatten(1)
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
        run(desc, test, stat, env)
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
        path_or_imp = case type
                      when :describe
                        imp
                      when :would
                        current
                      else
                        next r
                      end
        groups = opts[:groups]
        store_for_groups(r, path_or_imp, groups) if groups
        store_for_source(r, path_or_imp, *test.source_location)
        imp.build_all_tests(r, current) if type == :describe
        r
      end
    end

    def store_for_groups tests, path_or_imp, groups
      r = tests[:groups] ||= {}
      groups.each do |g|
        (r[g.to_s] ||= []) << path_or_imp
      end
    end

    def store_for_source tests, path_or_imp, file, line
      r = tests[:files] ||= {}
      ((r[File.expand_path(file)] ||= {})[line] ||= []) << path_or_imp
    end
  end

  Executor.extend(Shuffled)
end
