
module Pork
  # default to :auto while eliminating warnings for uninitialized ivar
  def self.inspect_failure_mode mode=nil; @mode = mode || @mode ||= :auto; end
  def self.inspect_failure *args
    lambda{ public_send("inspect_failure_#{inspect_failure_mode}", *args) }
  end

  def self.inspect_failure_auto object, msg, args, negate
    if args.size > 1
      inspect_failure_inline(object, msg, args, negate)

    elsif object.kind_of?(Hash) && args.first.kind_of?(Hash)
      inspect_failure_inline(Hash[object.sort], msg,
                             [Hash[args.first.sort]], negate)

    elsif object.kind_of?(String) && object.size > 400 &&
          object.count("\n") > 4 && !`which diff`.empty?
      inspect_failure_diff(object, msg, args, negate)

    elsif object.inspect.size > 78
      inspect_failure_newline(object, msg, args, negate)

    else
      inspect_failure_inline( object, msg, args, negate)
    end
  end

  def self.inspect_failure_inline object, msg, args, negate
    a = args.map(&:inspect).join(', ')
    "#{object.inspect}.#{msg}(#{a}) to return #{!negate}"
  end

  def self.inspect_failure_newline object, msg, args, negate
    a = args.map(&:inspect).join(",\n")
    "\n#{object.inspect}.#{msg}(\n#{a}) to return #{!negate}"
  end

  def self.inspect_failure_diff object, msg, args, negate
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
end
