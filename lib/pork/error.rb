
module Pork
  Error   = Class.new(StandardError)
  Failure = Class.new(Error)
  Skip    = Class.new(Error)
  Bug     = Class.new(Error)
end
