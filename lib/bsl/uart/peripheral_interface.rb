# frozen_string_literal: true

module Bsl
  module Uart
    class PeripheralInterface
      include Utils

      MIN_PACKET_SIZE = 6.freeze     # bytes
      OK_HEADER       = 0x80.freeze

      HEADER_SIZE   = 1.freeze
      DATA_LEN_SIZE = 2.freeze
      CRC_SIZE      = 2.freeze


      class << self
        include Utils

        def wrap(command)
          unless command.is_a?(Command)
            raise Exceptions::PeripheralInterfaceWrapNotACommand, command
          end

          new header: OK_HEADER, data_len: command.length, data: [command.code]
        end

        def parse(raw_data)
          raise Exceptions::PeripheralInterfaceParseRawDataNotArray unless raw_data.is_a?(Array)
          raise Exceptions::PeripheralInterfaceSize, raw_data.size unless raw_data.size >= MIN_PACKET_SIZE

          header = raw_data[0]
          data_len = raw_data[2] << 8 | raw_data[1]
          data = raw_data[3, data_len]
          crc = raw_data[-1] << 8 | raw_data[-2]

          new header: header, data_len: data_len, data: data, crc: crc
        end
      end

      attr_reader :header, :data_len, :data, :crc, :errors, :packet, :cmd_kind

      def initialize(header: nil, data_len: nil, data: nil, crc: nil)
        raise Exceptions::PeripheralInterfaceDataNotArray if (data && !data.is_a?(Array))

        @header = header
        @data_len = data_len
        @data = data
        @crc = crc ? crc : (data ? crc16(data) : nil)
        @cmd_code

        @partial_data = []
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

      def push(val)
        @partial_data.append *val

        # If :header has not already been fetched
        if !header && @partial_data.size >= HEADER_SIZE
          @header = @partial_data.shift
        end
        # If :data_len has not already been fetched, and we have enough data
        if header && !data_len && @partial_data.size >= DATA_LEN_SIZE
          values = @partial_data.shift DATA_LEN_SIZE
          @data_len = values[0] | (values[1] << 8)
        end

        # If :data has not already been fetched, fetch it
        if data_len && (data.nil? || data.empty?) && @partial_data.size >= data_len
          @data = @partial_data.shift data_len
        end

        if data && !crc && @partial_data.size >= CRC_SIZE
          values = @partial_data.shift CRC_SIZE
          @crc = values[0] | (values[1] << 8)
        end
      end

      alias_method :<<, :push

      def to_hex_ary_str
        packet.to_hex
      end

      def to_uart
        packet.to_chr_string
      end

      def valid?
        @errors = []
        @errors << [:header, 'Header NOK'] unless header_ok?
        @errors << [:data_len, "data_len value (#{data_len}) differs from actual data length (#{data.length})"] unless data_len_ok?
        @errors << [:crc, 'CRC NOK'] unless crc_ok?

        @errors.empty?
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
