
require 'pork/test'

describe Pork::Suite do
  def self.suite_method
    would{ ok }
  end

  suite_method
end
