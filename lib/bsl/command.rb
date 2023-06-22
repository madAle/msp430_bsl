module Bsl
  class Command

    RX_DATA_BLOCK         = 0x10
    RX_DATA_BLOCK_FAST    = 0x1B
    RX_PASSWORD           = 0x11
    ERASE_SEGMENT         = 0x12
    LOCK_UNLOCK_INFO      = 0x13
    MASS_ERASE            = 0x15
    CRC_CHECK             = 0x16
    LOAD_PC               = 0x17
    TX_DATA_BLOCK         = 0x18
    TX_BSL_VERSION        = 0x19
    TX_BUFFER_SIZE        = 0x1A

    attr_accessor :name, :value

    def self.valid?(name)
      const_defined? name.to_s.upcase
    end

    def initialize(cmd_name)
      raise ArgumentError, "command #{cmd_name} is not valid" unless self.class.valid?(cmd_name)

      @name = cmd_name
      @value = self.class.const_get @name.to_s.upcase
    end

    def hex_value
      "0x#{value.to_hex_str}"
    end

    def length
      packet.length
    end

    def packet
      return @packet if @packet

      command = [value]
      cmd_len = command.length
      # Calculate CRC (it must be calculated only on command data)
      crc = crc16 command
      # Prepend preamble
      command.prepend 0x80, (cmd_len & 0xFF), ((cmd_len >> 8) & 0xFF)
      # Append CRC16
      @packet = command.append (crc & 0xFF), ((crc >> 8) & 0xFF)
    end

    def to_hex_ary_str
      packet.to_hex
    end

    def to_uart
      packet.to_chr_string
    end

    private

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
