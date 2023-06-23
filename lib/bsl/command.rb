module Bsl
  class Command

    MESSAGES = {
      rx_data_block:      { code: 0x10, requires_addr: true, requires_data: true },
      rx_data_block_fast: { code: 0x1B, requires_addr: true, requires_data: true },
      rx_password:        { code: 0x11, requires_addr: false, requires_data: true },
      erase_segment:      { code: 0x12, requires_addr: true, requires_data: false },
      lock_unlock_info:   { code: 0x13, requires_addr: false , requires_data: false },
      reserved:           { code: 0x14, requires_addr: false , requires_data: false },
      mass_erase:         { code: 0x15, requires_addr: false , requires_data: false },
      crc_check:          { code: 0x16, requires_addr: true , requires_data: true },
      load_pc:            { code: 0x17, requires_addr: true, requires_data: false },
      tx_data_block:      { code: 0x18, requires_addr: true, requires_data: true },
      tx_bsl_version:     { code: 0x19, requires_addr: false , requires_data: false },
      tx_buffer_size:     { code: 0x1A, requires_addr: false , requires_data: false }
    }

    attr_accessor :name, :code, :addr, :data, :value

    def self.valid?(cmd_name)
      MESSAGES.keys.include? cmd_name.to_sym
    end

    def self.[](cmd_name)
      raise ArgumentError, "command #{cmd_name} is not a valid BSL CMD code" unless valid?(cmd_name)

      MESSAGES[cmd_name.to_sym]
    end

    def initialize(cmd_name, addr: nil, data: nil)
      raise ArgumentError, "command #{cmd_name} is not a valid BSL CMD code" unless self.class.valid?(cmd_name)

      @name = cmd_name
      @value = self.class[@name]
      @code = @value[:code]
      @addr = addr
      @data = data

      validate
    end

    def [](key)
      key = key.to_sym
      raise ArgumentError, "attribute '#{key}' not valid" unless value.keys.include?(key)

      value[key]
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

    def validate
      # Check if command requires address and/or data
      if value[:requires_addr] && !value
        raise Exceptions::CommandRequiresAddr.new name
      end

      if value[:requires_data] && !data
        raise Exceptions::CommandRequiresData.new name
      end
    end
  end
end
