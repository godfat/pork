
require 'pork/test'

describe Pork::Isolator do
  before do
    @suite = Class.new(Pork::Suite){init}
  end

  describe '.all_tests' do
    would 'have the correct source order' do
      @suite.copy :append do
        would{}
      end

      @suite.describe do
        describe do
          would{}
        end

        paste :append
      end

      Pork::Isolator[@suite].
        all_tests[:files].values.map(&:keys).each do |lines|
          expect(lines).eq lines.sort
        end
    end
  end
end
