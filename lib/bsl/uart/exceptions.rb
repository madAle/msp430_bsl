module Bsl
  module Uart
    module Exceptions
      class PeripheralInterfaceSize < StandardError
        def initialize(received_size)
          message = "Peripheral Interface size error. Required min size is #{PeripheralInterface::MIN_PACKET_SIZE} bytes, received size is #{received_size} bytes"
          super(message)
        end
      end

      class PeripheralInterfaceHeaderNOK < StandardError
        def initialize(received_header)
          message = "Peripheral interface header NOK. Received '0x#{received_header.to_hex_str}' instead of 0x#{PeripheralInterface::OK_HEADER.to_hex_str}"
          super(message)
        end

      end

      class PeripheralInterfaceCRCMismatch < StandardError
        def initialize
          message = 'Peripheral Interface CRC mismatch'
          super(message)
        end
      end
    end
  end
end
