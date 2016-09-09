
require 'thread'
require 'pork/report'

module Pork
  Stat = Struct.new(:reporter, :protected_exceptions, :start, :mutex,
                    :tests, :assertions, :skips, :failures, :errors,
                    :exceptions)

  module Stat::Imp
    attr_accessor :stop
    def initialize rt=Pork.report_class.new,
                   protected_exceptions=Pork.protected_exceptions,
                   st=Time.now, mu=Mutex.new,
                   t=0, a=0, s=0, f=0, e=0, x=[]
      super
    end

    def incr_assertions; mutex.synchronize{ self.assertions += 1 }; end
    def incr_tests     ; mutex.synchronize{ self.tests      += 1 }; end
    def incr_skips     ; mutex.synchronize{ self.skips      += 1 }; end

    def add_failure err
      mutex.synchronize do
        self.failures += 1
        exceptions << err
      end
    end

    def add_error err
      mutex.synchronize do
        self.errors += 1
        exceptions << err
      end
    end

    def passed?; exceptions.empty?                           ; end
    def numbers; [tests, assertions, failures, errors, skips]; end

    def velocity
      time_spent = stop - start
      [time_spent.round(6),
       (tests / time_spent).round(4),
       (assertions / time_spent).round(4)]
    end

    def loaded at, files
      reporter.loaded(at, files)
    end

    def prepare paths
      reporter.prepare(paths)
    end

    def report
      self.stop = Time.now
      reporter.report(self)
    end

    def merge stat
      self.class.new(reporter, protected_exceptions, start, mutex,
        *to_a.drop(4).zip(stat.to_a.drop(4)).map{ |(a, b)| a + b })
    end
  end

  Stat.include(Stat::Imp)
end
