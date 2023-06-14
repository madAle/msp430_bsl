# frozen_string_literal: true

module Bsl
  class Connection

    CMD_RX_DATA_BLOCK         = 16
    CMD_RX_DATA_BLOCK_FAST    = 27
    CMD_RX_PASSWORD           = 17
    CMD_ERASE_SEGMENT         = 18
    CMD_LOCK_UNLOCK_INFO      = 19
    CMD_MASS_ERASE            = 21
    CMD_CRC_CHECK             = 22
    CMD_LOAD_PC               = 23
    CMD_TX_DATA_BLOCK         = 24
    CMD_TX_BSL_VERSION        = 25
    CMD_TX_BUFFER_SIZE        = 26

    BSL_OK                    = 0x00
    BSL_FLASH_WRITE_NOK       = 0x01
    BSL_FLASH_FAIL_BIT        = 0x02
    BSL_VOLTAGE_CHANGED       = 0x03
    BSL_LOCKED                = 0x04
    BSL_PASSWORD_ERROR        = 0x05
    BSL_BYTE_WRITE_FORBIDDEN  = 0x06
    BSL_UNKNOWN_COMMAND       = 0x07
    BSL_PACKET_TOO_LARGE      = 0x08
    BSL_DATA_BLOCK            = 0x3A
    BSL_MESSAGE               = 0x3B

    UART_ACK                  = 0x00
    UART_HEADER_NOK           = 0x51
    UART_CRC_NOK              = 0x52
    UART_PACKET_SIZE_ZERO     = 0x53
    UART_PACKET_SIZE_EXCEEDS  = 0x54
    UART_UNKNOWN_ERROR        = 0x55
    UART_UNKNOWN_BAUDRATE     = 0x56
    MEM_START_MAIN_FLASH      = 0x8000

    MAX_REPLY_TIME            = 1.0  # Seconds

    attr_reader :uart, :device_path, :logger

    def initialize(device_path, opts = {})
      @device_path = device_path
      @logger = opts.fetch :logger, Logger.new(STDOUT)

      @uart = Uart.new device_path, verbose: opts[:verbose], logger: @logger
    end

    def check_bsl_reply
      reply.length > 1 && reply[0] == 59 && reply[1] == 0
    end

    def enter_bsl
      logger.info "Connecting to target board on #{device_path}"
      uart.set_low_speed
      uart.invoke_bsl
    end

    def mass_erase_flash
      logger.info 'Mass erasing target EEPROM'


      logger.info 'OK, EEPROM erased'
    end

    def read_reply
      start_time = Time.now

      loop do


        break if Time.now - start_time >= MAX_REPLY_TIME
      end
    end

    private

    def send_command(command)
      raise ArgumentError, 'command must be an Array' unless command.is_a?(Array)

      length = command.length

      # Calculate CRC (it must be calculated only on command data)
      crc = crc16 command
      # Prepend preamble
      command.prepend 0x80, (length & 0xFF), ((length >> 8) & 0xFF)
      # Append CRC16
      command.append (crc & 0xFF), ((crc >> 8) & 0xFF)

      uart.write command
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
