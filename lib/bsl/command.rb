# frozen_string_literal: true

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

    def self.supports?(cmd_name)
      MESSAGES.keys.include? cmd_name.to_sym
    end

    def self.[](cmd_name)
      raise Exceptions::Command::NameNotSupported, cmd_name unless supports?(cmd_name)

      MESSAGES[cmd_name.to_sym]
    end

    def initialize(cmd_name, addr: nil, data: nil)
      raise Exceptions::Command::NameNotSupported, cmd_name unless supports?(cmd_name)

      @name = cmd_name
      @value = self.class[@name]
      @code = @value[:code]
      @addr = addr
      @data = data

      validate
    end

    def length
      code.to_bytes_ary.length
    end

    def validate
      # Check if command requires address and/or data
      if value[:requires_addr] && !value
        raise Exceptions::Command::RequiresAddr.new name
      end

      if value[:requires_data] && !data
        raise Exceptions::Command::RequiresData.new name
      end
    end
  end
end
