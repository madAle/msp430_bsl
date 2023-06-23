# frozen_string_literal: true

module Bsl
  module Exceptions
    module Command

      class NameNotSupported < StandardError
        def initialize(given_name)
          message = "command '#{given_name}' not recognized. Supported commands: #{Command::MESSAGES.keys}"
          super(message)
        end
      end

      class RequiresAddr < StandardError
        def initialize(cmd_name)
          msg = "command '#{cmd_name}' requires 'addr' param"
          super(msg)
        end
      end

      class RequiresData < StandardError
        def initialize(cmd_name)
          msg = "command '#{cmd_name}' requires 'data' param"
          super(msg)
        end
      end

    end

    module Response
      class CMDNotSupported < StandardError
        def initialize(cmd)
          message = "CMD '#{cmd}' not recognized. Supported response CMDs: #{Bsl::Response::CMD.keys}"
          super(message)
        end
      end

      class MessageNotSupported < StandardError
        def initialize(cmd, message)
          message = "message name '#{message}' not recognized. Supported response MESSAGES: #{Bsl::Response::CMD[cmd].keys}"
          super(message)
        end
      end

      class NotEnoughData < StandardError
        def initialize(data)
          message = "payload with a size of '#{data.size}' doesn't satisfy the min required size of '#{Bsl::Response::PAYLOAD_MIN_SIZE}'"
          super(message)
        end
      end
    end
  end
end
