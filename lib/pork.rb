
require 'pork/executor'
require 'pork/ext'

module Pork
  Error   = Class.new(StandardError)
  Failure = Class.new(Error)
  Skip    = Class.new(Error)

  module API
    module_function
    def before &block; Executor.before(&block); end
    def after  &block; Executor.after( &block); end
    def describe desc=:default, &suite; Executor.describe(desc, &suite); end
    def copy     desc=:default, &suite; Executor.copy(    desc, &suite); end
    def paste    desc=:default, *args ; Executor.paste(   desc, *args ); end
    def would    desc=:default, &test ; Executor.would(   desc, &test ); end
    def expect *args, &block; Expect.new(Executor, *args, &block); end
  end

  def self.report_at_exit
    @report_at_exit ||= at_exit do
      Executor.execute
      Executor.stat.report
      exit Executor.stat.failures.size +
           Executor.stat.errors.size + ($! && 1).to_i
    end
  end
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
    else
      ins = object.inspect
      if ins.size > 78
        inspect_failure_newline(object, msg, args, negate)
      else
        inspect_failure_inline( object, msg, args, negate)
      end
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
