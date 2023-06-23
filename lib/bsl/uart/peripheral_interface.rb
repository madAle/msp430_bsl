module Bsl
  module Uart
    class PeripheralInterface

      MIN_PACKET_SIZE = 6     # bytes
      OK_HEADER       = 0x80

      attr_reader :raw_data, :header, :data_len, :data, :crc

      def initialize(raw_data)
        raise ArgumentError, 'raw_data must be an Array' unless raw_data.is_a?(Array)

        @raw_data = raw_data

        parse_raw_data
      end

      def crc_ok?
        crc == crc16(data)
      end

      def header_ok?
        header == OK_HEADER
      end

      def valid?
        header_ok? && crc_ok?
      end

      def errors
        res = []
        res << [:header, 'Header NOK'] unless header_ok?
        res << [:crc, 'CRC NOK'] unless crc_ok?

        res
      end

      private

      def parse_raw_data
        @header = raw_data[0]
        @data_len = raw_data[2] << 8 | raw_data[1]
        @data = raw_data[3, data_len]
        @crc = raw_data[-1] << 8 | raw_data[-2]
      end

      def crc16(data)
        raise ArgumentError, 'data mus be an Array' unless data.is_a?(Array)

        crc = 0xFFFF

        data.each do |byte|
          x = (crc >> 8 ^ byte) & 0xFF
          x ^= x >> 4
          crc = (crc << 8) ^ (x << 12) ^ (x << 5) ^ x
        end

        crc & 0xFFFF
      end
    end
  end
end
