
module Pork
  # default to :auto while eliminating warnings for uninitialized ivar
  def self.inspect_failure_mode mode=nil
    @mode = mode || @mode ||= :auto
  end

  class Inspect < Struct.new(:flip)
    def self.with *args
      lambda{ public_send("with_#{Pork.inspect_failure_mode}", *args) }
    end

    def self.with_auto expect, msg, args, negate
      if args.size > 1
        with_inline(expect, msg, args, negate)

      elsif expect.kind_of?(Hash) && args.first.kind_of?(Hash)
        if expect.inspect.size > 78
          for_diff_hash(msg, negate,
            Inspect.new(true).diff_hash(expect, args.first).
              merge(Inspect.new(false).diff_hash(args.first, expect)))
        else
          with_inline(Hash[expect.sort], msg, [Hash[args.first.sort]], negate)
        end

      elsif expect.kind_of?(String) && expect.size > 400 &&
            expect.count("\n") > 4 && !`which diff`.empty?
        with_diff(expect, msg, args, negate)

      elsif expect.inspect.size > 78
        with_newline(expect, msg, args, negate)

      else
        with_inline( expect, msg, args, negate)
      end
    end

    def self.with_inline expect, msg, args, negate
      a = args.map(&:inspect).join(', ')
      "#{expect.inspect}.#{msg}(#{a}) to return #{!negate}"
    end

    def self.with_newline expect, msg, args, negate
      a = args.map(&:inspect).join(",\n")
      "\n#{expect.inspect}.#{msg}(\n#{a}) to return #{!negate}"
    end

    def self.with_diff expect, msg, args, negate
      require 'tempfile'
      Tempfile.open('pork-expect') do |its|
        Tempfile.open('pork-was') do |was|
          its.puts(expect.to_s)
          its.close
          was.puts(args.map(&:to_s).join(",\n"))
          was.close
          name = "#{expect.class}##{msg}(\n"
          "#{name}#{`diff #{its.path} #{was.path}`}) to return #{!negate}"
        end
      end
    end

    def diff_hash expect, actual, result={}, prefix=''
      expect.inject(result) do |r, (key, e)|
        diff_object(e, actual[key], r, "#{prefix}#{key}")
      end
    end

    def diff_array expect, actual, result={}, prefix=''
      expect.each.with_index.inject(result) do |r, (e, idx)|
        diff_object(e, actual[idx], r, "#{prefix}#{idx}")
      end
    end

    def diff_object expect, actual, result, prefix
      return result if expect == actual

      if expect.kind_of?(Hash) && actual.kind_of?(Hash)
        diff_hash(expect, actual, result, "#{prefix}:")
      elsif expect.kind_of?(Array) && actual.kind_of?(Array)
        diff_array(expect, actual, result, "#{prefix}:")
      elsif flip
        result[prefix] = [actual, expect]
      else
        result[prefix] = [expect, actual]
      end

      result
    end
  end
end
