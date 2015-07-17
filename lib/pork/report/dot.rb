
require 'pork/report'

module Pork
  class Dot < Report
    def msg_pass   ; '.'; end
    def msg_skip   ; 's'; end
    def msg_failed ; 'F'; end
    def msg_errored; 'E'; end
  end
end
