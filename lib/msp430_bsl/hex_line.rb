# frozen_string_literal: true

module Msp430Bsl
  class HexLine
    include Utils
    extend Utils

    attr_reader :raw_data, :data_length, :addr, :type, :data, :crc, :number, :end_addr

    RECORD_TYPES = {
      data: 0x00,
      eof: 0x01,
      ext_seg_addr: 0x02,
      start_seg_addr: 0x03,
      ext_lin_addr: 0x04,
      start_lin_addr: 0x05
    }.freeze

    def initialize(data, num: nil)
      raise StandardError, 'raw_data must be a String' unless data.is_a?(String)

      # Strip String, remove first char i.e. ':' and convert char couples to its hex value.
      if data[0] == ':'
        @raw_data = data.strip[1..-1]
      end
      # Convert raw data to hex array
      @raw_data = @raw_data.to_hex_ary

      # Extract data length
      @data_length = raw_data[0]
      # Extract addr
      @addr = (raw_data[1] << 8) | raw_data[2]
      # Extract line type
      @type = raw_data[3]
      # Extract data
      @data = raw_data.slice 4, data_length
      # Extract CRC
      @crc = raw_data[-1]
      @number = num
      @end_addr = addr + data_length
    end

    # Checks if this line's address is contiguous with the one of the given line
    # Obviously this can be true only if the given line has an address that precedes this line's one
    def has_addr_contiguous_to?(another_line)
      another_line.end_addr == addr
    end

    def crc_ok?
      crc == crc8(raw_data[0..-2])
    end

    def is_of_type?(ty)
      ty = ty.to_sym
      type == RECORD_TYPES[ty]
    end

    def to_s
      ":#{@data_length.to_hex_str}#{@addr.to_hex_str}#{@type.to_hex_str}#{data.to_hex.join}#{@crc.to_hex_str}"
    end
  end
end
