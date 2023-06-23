# frozen_string_literal: true

module Bsl
  module Exceptions
    class CommandRequiresAddr < StandardError
      def initialize(cmd_name)
        msg = "command '#{cmd_name}' requires 'addr' param"
        super(msg)
      end
    end

    class CommandRequiresData < StandardError
      def initialize(cmd_name)
        msg = "command '#{cmd_name}' requires 'data' param"
        super(msg)
      end
    end
  end
end
