
module Pork
  # default to :auto while eliminating warnings for uninitialized ivar
  def self.inspect_failure_mode mode=nil
    @mode = mode || @mode ||= :auto
  end

  class Inspect < Struct.new(:flip)
    def self.with *args
      lambda{ public_send("with_#{Pork.inspect_failure_mode}", *args) }
    end

    def self.with_auto object, msg, args, negate
      if args.size > 1
        with_inline(object, msg, args, negate)

      elsif object.kind_of?(Hash) && args.first.kind_of?(Hash)
        if object.inspect.size > 78
          require 'pp'
          Inspect.new(true).diff_hash(object, args.first).
            merge(Inspect.new(false).diff_hash(args.first, object)).
              pretty_inspect
        else
          with_inline(Hash[object.sort], msg, [Hash[args.first.sort]], negate)
        end

      elsif object.kind_of?(String) && object.size > 400 &&
            object.count("\n") > 4 && !`which diff`.empty?
        with_diff(object, msg, args, negate)

      elsif object.inspect.size > 78
        with_newline(object, msg, args, negate)

      else
        with_inline( object, msg, args, negate)
      end
    end

    def self.with_inline object, msg, args, negate
      a = args.map(&:inspect).join(', ')
      "#{object.inspect}.#{msg}(#{a}) to return #{!negate}"
    end

    def self.with_newline object, msg, args, negate
      a = args.map(&:inspect).join(",\n")
      "\n#{object.inspect}.#{msg}(\n#{a}) to return #{!negate}"
    end

    def self.with_diff object, msg, args, negate
      require 'tempfile'
      Tempfile.open('pork-expect') do |expect|
        Tempfile.open('pork-was') do |was|
          expect.puts(object.to_s)
          expect.close
          was.puts(args.map(&:to_s).join(",\n"))
          was.close
          name = "#{object.class}##{msg}(\n"
          "#{name}#{`diff #{expect.path} #{was.path}`}) to return #{!negate}"
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
