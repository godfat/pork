
* introduce configs
* executable
* [BUG] Picking the top-level describe block should pick up tests for nested
  describe block. For the following it should pick all the tests for the
  top level describe.

  ``` ruby
  describe 'set the same visibility from the original method' do
    copy :test do
      def find_visibilities klass
        %i[public protected private].map do |v|
          klass.send("#{v}_method_defined?", :hello)
        end
      end

      would do
        visibilities = find_visibilities(klass)

        stub(klass).hello{ :stub }

        expect(visibilities).eq find_visibilities(klass)
      end
    end

    describe 'for direct method' do
      def klass
        @klass ||= Class.new do
          private
          def hello; :hello; end
        end
      end

      paste :test
    end
  end
  ```
