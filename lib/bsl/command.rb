# frozen_string_literal: true

module Bsl
  class Command

    attr_accessor :name, :code, :addr, :data, :configs

    def self.supports?(cmd_name)
      Configs::CMDS.keys.include? cmd_name.to_sym
    end

    def self.[](cmd_name)
      raise Exceptions::Command::NameNotSupported, cmd_name unless supports?(cmd_name)

      Configs::CMDS[cmd_name.to_sym]
    end

    def initialize(cmd_name, addr: nil, data: nil)
      raise Exceptions::Command::NameNotSupported, cmd_name unless self.class.supports?(cmd_name)

      @name = cmd_name
      @configs = self.class[@name]
      @code = configs[:code]
      @addr = addr
      @data = data

      validate
    end

    def packet
      [code, addr, data].flatten.compact
    end

    def length
      code.to_bytes_ary.length
    end

    private

    def validate
      # Check if command requires address and/or data
      if configs[:requires_addr] && !addr
        raise Exceptions::Command::RequiresAddr.new name
      end

      if configs[:requires_data] && !data
        raise Exceptions::Command::RequiresData.new name
      end
    end
  end
end
