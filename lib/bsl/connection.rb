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

    BSL_OK                    = 0
    BSL_FLASH_WRITE_NOK       = 1
    BSL_FLASH_FAIL_BIT        = 2
    BSL_VOLTAGE_CHANGED       = 3
    BSL_LOCKED                = 4
    BSL_PASSWORD_ERROR        = 5
    BSL_BYTE_WRITE_FORBIDDEN  = 6
    BSL_UNKNOWN_COMMAND       = 7
    BSL_PACKET_TOO_LARGE      = 8
    BSL_DATA_BLOCK            = 58
    BSL_MESSAGE               = 59

    UART_ACK                  = 0
    UART_HEADER_NOK           = 81
    UART_CRC_NOK              = 82
    UART_PACKET_SIZE_ZERO     = 83
    UART_PACKET_SIZE_EXCEEDS  = 84
    UART_UNKNOWN_ERROR        = 85
    UART_UNKNOWN_BAUDRATE     = 86
    MEM_START_MAIN_FLASH      = 32768

    attr_reader :uart

    def initialize(device_path, verbose)
      @uart = Uart.new device_path, verbose
    end

    def mass_erase

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
