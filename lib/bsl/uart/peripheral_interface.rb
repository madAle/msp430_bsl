# frozen_string_literal: true

module Bsl
  module Uart
    class PeripheralInterface
      include Utils

      MIN_PACKET_SIZE = 6     # bytes
      OK_HEADER       = 0x80

      class << self
        include Utils

        def wrap(command)
          unless command.is_a?(Command)
            raise Exceptions::PeripheralInterfaceWrapNotACommand, command
          end

          new OK_HEADER, command.length, [command.code]
        end

        def parse(raw_data)
          raise Exceptions::PeripheralInterfaceParseRawDataNotArray unless raw_data.is_a?(Array)
          raise Exceptions::PeripheralInterfaceSize, raw_data.size unless raw_data.size >= MIN_PACKET_SIZE

          header = raw_data[0]
          data_len = raw_data[2] << 8 | raw_data[1]
          data = raw_data[3, data_len]
          crc = raw_data[-1] << 8 | raw_data[-2]

          new header, data_len, data, crc
        end
      end

      attr_reader :header, :data_len, :data, :crc, :errors, :packet, :cmd_kind

      def initialize(header, data_len, data, crc = nil)
        raise Exceptions::PeripheralInterfaceDataNotArray unless data.is_a?(Array)

        @header = header
        @data_len = data_len
        @data = data
        @crc = crc || crc16(data)
        @cmd_code
      end

      def crc_ok?
        crc == crc16(data)
      end

      def header_ok?
        header == OK_HEADER
      end

      def data_len_ok?
        data.length == data_len
      end

      def valid?
        @errors = []
        @errors << [:header, 'Header NOK'] unless header_ok?
        @errors << [:data_len, "data_len value (#{data_len}) differs from actual data length (#{data.length})"] unless data_len_ok?
        @errors << [:crc, 'CRC NOK'] unless crc_ok?

        @errors.empty?
      end

      def length
        packet.length
      end

      def packet
        res = data.clone
        cmd_len = res.length
        # Calculate CRC (it must be calculated only on command data)
        crc = crc16 res
        # Prepend preamble
        res.prepend 0x80, (cmd_len & 0xFF), ((cmd_len >> 8) & 0xFF)
        # Append CRC16
        res.append (crc & 0xFF), ((crc >> 8) & 0xFF)
      end

      def to_hex_ary_str
        packet.to_hex
      end

      def to_response(expected_message_name)
        Response.new data, expected_message_name
      end

      def to_uart
        packet.to_chr_string
      end

      private

      def parse_raw_data
        @header = raw_data[0]
        @data_len = raw_data[2] << 8 | raw_data[1]
        @data = raw_data[3, data_len]
        @crc = raw_data[-1] << 8 | raw_data[-2]
      end
    end
  end
end
