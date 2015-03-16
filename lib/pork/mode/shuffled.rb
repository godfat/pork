
require 'pork'

module Pork
  module Shuffled
    def all_tests
      @all_tests ||= build_all_tests
    end

    def all_paths
      all_tests.values.flat_map(&:values).flatten(1)
    end

    def [] source_location
      file_str, line_str = source_location.split(':')
      file, line = File.expand_path(file_str), line_str.to_i
      return unless tests = all_tests[file]
      _, paths = tests.reverse_each.find{ |(l, _)| l <= line }
      paths
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
      @tests.each_with_index.inject(result) do |r, ((type, arg, test), index)|
        current = path + [index]
        case type
        when :describe
          arg.build_all_tests(r, current)
        when :would
          loc = test.source_location
          ((r[loc.first] ||= {})[loc.last] ||= []) << current
        end
        r
      end
    end
  end

  Executor.extend(Shuffled)
end
