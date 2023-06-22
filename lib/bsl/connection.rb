# frozen_string_literal: true
require 'logger'

module Bsl
  class Connection

    MEM_START_MAIN_FLASH      = 0x8000

    MAX_BSL_RESPONSE_SIZE     = 240

    attr_reader :uart, :device_path, :logger

    def initialize(device_path, opts = {})
      @device_path = device_path
      @logger = opts.fetch :logger, Logger.new(STDOUT)

      @uart = Uart.new device_path, verbose: opts[:verbose], logger: @logger
    end

    def check_bsl_reply
      reply.length > 1 && reply[0] == BSL_MESSAGE && reply[1] == BSL_OK
    end

    def enter_bsl
      logger.info "Connecting to target board on #{device_path}"
      uart.set_low_speed
      uart.invoke_bsl
    end

    def mass_erase_flash
      logger.info 'Mass erasing target EEPROM'
      send_command [CMD_MASS_ERASE]
      logger.info 'OK, EEPROM erased'
    end

    def send_command(cmd_name)
      command = Command.new cmd_name
      # Flush serial's output and input before sending a new command
      uart.flush_output
      uart.flush_input

      logger.debug "OUT -> (#{command.length} bytes) #{command.to_hex_ary_str}"
      uart.write command.to_uart

      uart.read_response
    end
  end
end
