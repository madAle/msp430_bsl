# frozen_string_literal: true

module Msp430Bsl
  module Uart
    module Exceptions
      module Ack

        class NOK <  StandardError
          def initialize(val)
            message = "Command ACK not OK. Received value: #{val}"
            super(message)
          end
        end
        class MessageNotSupported < StandardError
          def initialize(value)
            message = if value
                        "message with value 0x#{value.to_hex_str} not supported"
                      else
                        "message without a value"
                      end
            super(message)
          end
        end
      end

      module PeripheralInterface
        class InterfaceWrapNotACommand < StandardError
          def initialize(arg)
            message = "Given argument '#{arg}' must be a Msp430Bsl::Command"
            super(message)
          end
        end

        class InterfaceParseRawDataNotArray < StandardError
          def initialize
            message = "PeripheralInterface#parse argument must be an Array"
            super(message)
          end
        end

        class InterfaceDataNotArray < StandardError
          def initialize
            message = "Peripheral Interface 'data' argument must be an Array"
            super(message)
          end
        end

        class InterfaceSize < StandardError
          def initialize(received_size)
            message = "Peripheral Interface size error. Required packet's min size is '#{PeripheralInterface::MIN_PACKET_SIZE}' bytes, given raw_data size is '#{received_size}' bytes"
            super(message)
          end
        end

        class InterfaceHeaderNOK < StandardError
          def initialize(received_header)
            message = "Peripheral interface header NOK. Received '0x#{received_header.to_hex_str}' instead of 0x#{PeripheralInterface::OK_HEADER.to_hex_str}"
            super(message)
          end

        end

        class InterfaceCRCMismatch < StandardError
          def initialize
            message = 'Peripheral Interface CRC mismatch'
            super(message)
          end
        end
      end
    end
  end
end
