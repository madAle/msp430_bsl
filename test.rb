require 'digest/crc16_ccitt'

module Digest
  class CRC3000 < CRC16CCITT

    INIT_CRC = 0xffffffff

    XOR_MASK = 0xffffffff

    def update(data)
      data.each do |b|
        @crc = (((@crc >> 8) & 0x00ffffff) ^ @table[(@crc ^ b) & 0xff])
      end

      return self
    end
  end
end


p Digest::CRC3000.new.update [0x15]