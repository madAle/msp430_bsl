# frozen_string_literal: true

module Bsl
  class HexLine
    include Utils

    attr_reader :raw_data, :data_length, :addr, :type, :data, :crc

    RECORD_TYPES = {
      data: 0x00,
      eof: 0x01,
      ext_seg_addr: 0x02,
      start_seg_addr: 0x03,
      ext_lin_addr: 0x04,
      start_lin_addr: 0x05
    }.freeze

    def initialize(data)
      raise StandardError, 'raw_data must be a String' unless data.is_a?(String)

      # Strip String, remove first char i.e. ':' and convert char couples to its hex value.
      @raw_data = data.strip[1..-1].to_hex_ary

      @data_length = raw_data[0]
      @addr = (raw_data[1] << 8) | raw_data[2]
      @type = raw_data[3]
      @data = raw_data.slice 4, data_length
      @crc = raw_data[-1]
    end

    def is_of_type?(ty)
      ty = ty.to_sym
      type == RECORD_TYPES[ty]
    end

    def crc_ok?
      crc == crc8(raw_data[0..-2])
    end
  end
end
