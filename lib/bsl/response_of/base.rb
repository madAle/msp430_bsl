module Bsl
  module ResponseOf
    class Base

      attr_accessor :value, :message

      def initialize(*args)
        fail "This class must be subclassed. Do not use it directly"
      end

      def ok?
        value == 0x00
      end

      def reason
        message[:reason]
      end
    end
  end
end
