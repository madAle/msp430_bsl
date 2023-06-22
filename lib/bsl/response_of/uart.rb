module Bsl
  module ResponseOf
    class Uart < Base

      MESSAGES = {
        0x00 => { code: :ack, reason: 'ACK - Command correctly received' },
        0x51 => { code: :header_nok, reason: 'Header incorrect. The packet did not begin with the required 0x80 value' },
        0x52 => { code: :crc_nok, reason: 'Checksum incorrect. The packet did not have the correct checksum value' },
        0x53 => { code: :packet_size_zero, reason: 'Packet size zero. The size for the BSL core command was given as 0' },
        0x54 => { code: :packet_size_exceeds, reason: 'Packet size exceeds buffer. The packet size given is too big for the RX buffer' },
        0x55 => { code: :unkown_error, reason: 'Unknown error' },
        0x56 => { code: :unkown_baudrate, reason: 'Unknown baud rate. The supplied data for baud rate change is not a known value' }
      }

      def initialize(value)
        raise ArgumentError, 'message not supported' unless MESSAGES.include?(value)

        @value = value
        @message = MESSAGES[@value]
      end
    end
  end
end
