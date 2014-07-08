
require 'pork'

module M
  def m
    object_id
  end
end

Pork::API.describe 'A' do
  include M

  def f
    object_id
  end

  would 'f' do
    f.should == m
  end

  describe 'B' do
    would 'have the same context' do
      f.should == m
    end
  end
end

# require 'bacon'
# Bacon.summary_on_exit

# module M
#   def m
#     object_id
#   end
# end

# Bacon::Context.include M

# describe 'A' do
#   def f
#     object_id
#   end

#   should 'f' do
#     f.should == m
#   end

#   describe 'B' do
#     should 'have the same context' do
#       f.should == m
#     end
#   end
# end
