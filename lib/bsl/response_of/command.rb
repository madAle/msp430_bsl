module Bsl
  module ResponseOf
    class Command < Base

      MESSAGES = {
         0x00 => { code: :success, reason: 'Operation Successful' },
         0x01 => { code: :flash_write_check_failed, reason: 'Flash Write Check Failed. After programming, a CRC is run on the programmed data. If the CRC does not match the expected result, this error is returned' },
         0x02 => { code: :flash_fail_bit_set, reason: "Flash Fail Bit Set. An operation set the FAIL bit in the flash controller (see the MSP430F5xx and MSP430F6xx Family User's Guide for more details on the flash fail bit)" },
         0x03 => { code: :voltage_changed, reason: "Voltage Change During Program. The VPE was set during the requested write operation (see the MSP430F5xx and MSP430F6xx Family User's Guide for more details on the VPE bit)" },
         0x04 => { code: :bsl_locked, reason: 'BSL Locked. The correct password has not yet been supplied to unlock the BSL' },
         0x05 => { code: :bsl_password_error, reason: 'BSL Password Error. An incorrect password was supplied to the BSL when attempting an unlock' },
         0x06 => { code: :byte_write_forbidden, reason: 'Byte Write Forbidden. This error is returned when a byte write is attempted in a flash area' },
         0x07 => { code: :unknown_command, reason: 'Unknown Command. The command given to the BSL was not recognized.' },
         0x08 => { code: :packet_too_large, reason: 'Packet Length Exceeds Buffer Size. The supplied packet length value is too large to be held in the BSL receive buffer' }
      }

      KINDS = {
        bsl_data_block: 0x3A,
        bsl_message: 0x3B
      }

      attr_reader :raw_data, :ack

      def initialize(raw_data)
        raise ArgumentError, 'raw_data must be an Array' unless raw_data.is_a?(Array)

        @raw_data = raw_data
        check_and_parse_data
      end

      private

      def check_and_parse_data
        @ack = raw_data.first == UART_ACK
      end
    end
  end
end
