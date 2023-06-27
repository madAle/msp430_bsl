# frozen_string_literal: true

module Msp430Bsl
  module Exceptions
    module Command
      class NameNotSupported < StandardError
        def initialize(given_name)
          message = "command '#{given_name}' not recognized. Supported commands: #{Configs::CMDS.keys}"
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
      class KindNotSupported < StandardError
        def initialize(kind)
          message = "Response kind '0x#{kind.to_hex_str}' not recognized. Supported response kinds: #{Configs::CMD_KINDS.keys}"
          super(message)
        end
      end

      class NotValid < StandardError
        def initialize(errors)
          message = "Response not valid. Errors: \n\n#{errors.map { |err| " - #{err[1]}" }.join "\n" }\n"
          super(message)
        end
      end

      class WrongDataSize < StandardError
        def initialize(data, size, min: false)
          message = "payload with a size of '#{data.size}' doesn't satisfy the required #{min ? 'min' : ''}size of '#{size}'"
          super(message)
        end
      end
    end
  end
end
