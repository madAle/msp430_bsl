# frozen_string_literal: true
require 'logger'
require 'timeout'

module Bsl
  module Uart
    class Connection

      CONFIGS = {
        low_speed: { baud: 9600, data_bits: 8, stop_bits: 1, parity: SerialPort::EVEN }.transform_keys(&:to_s),
        high_speed: { baud: 57600, data_bits: 8, stop_bits: 1, parity: SerialPort::EVEN }.transform_keys(&:to_s)
      }.freeze

      WAIT_FOR_ACK_MAX      = 50.millis
      WAIT_FOR_RESPONSE_MAX = 50.millis

      MEM_START_MAIN_FLASH      = 0x8000

      MAX_BSL_RESPONSE_SIZE     = 240

      attr_reader :serial_port, :device_path, :logger

      def initialize(device_path, opts = {})
        @device_path = device_path
        @logger = opts.fetch :logger, Logger.new(STDOUT)

        @serial_port = SerialPort.new @device_path
      end

      def check_bsl_reply
        reply.length > 1 && reply[0] == BSL_MESSAGE && reply[1] == BSL_OK
      end

      def enter_bsl
        logger.info "Connecting to target board through UART on #{device_path}"
        uart.set_low_speed
        uart.invoke_bsl
      end

      def read_response
        res = []
        # Wait for first response byte - UART's ACK/NACK
        uart_response = nil
        begin
          Timeout::timeout(WAIT_FOR_ACK_MAX) do
            uart_response = ResponseOf::Uart.new serial_port.readbyte 1
          end
        rescue Timeout::Error
          logger.error 'Timeout occurred while waiting for UART ACK'
          return nil
        end

        # If we arrived here, uart_response has been populated
        unless uart_response.ok?
          logger.error uart_response.reason
          return nil
        end

        # Wait for command response
        begin
          Timeout::timeout(WAIT_FOR_RESPONSE_MAX) do
            cmd_response = UartResponse.new serial_port.readbyte 1
          end
        rescue Timeout::Error
          logger.error 'Timeout occurred while waiting for UART ACK'
          return nil
        end

        res
      end

      def send_command(cmd_name, addr: nil, data: nil)
        command = Command.new cmd_namem addr: addr, data: data
        logger.info "Sending command '#{command.name}' over UART"
        # Flush serial's output and input before sending a new command
        uart.flush_output
        uart.flush_input

        logger.debug "OUT -> (#{command.length} bytes) #{command.to_hex_ary_str}"
        uart.write command.to_uart

        uart.read_response
      end

      def set_high_speed
        logger.debug 'Serial port entering HIGH speed'
        serial_port.set_modem_params CONFIGS[:high_speed]
        serial_port.rts = true
        serial_port.dtr = false
      end

      def set_low_speed
        logger.debug 'Serial port entering LOW speed'
        serial_port.set_modem_params CONFIGS[:low_speed]
      end

      def trigger_reset
        # slau319 pag. 5 - Fig. 1-1
        reset_pin_go :low
        test_pin_go :low
        sleep_ms 5
        reset_pin_go :high
      end

      private

      def convert_pin(value, negate: false)
        res = case value
              when Symbol
                value == :high ? 1 : 0
              when Numeric
                value == 1 ? 1 : 0
              when TrueClass
                1
              when FalseClass
                0
              else
                raise ArgumentError, 'convert_pin: value not supported'
              end

        if negate
          res = res == 1 ? 0 : 1
        end

        res
      end

      def invoke_bsl
        serial_port.flush_input
        serial_port.flush_output

        logger.info 'Entering BSL...'

        test_pin_go(:low)
        reset_pin_go(:low)
        sleep 5.millis
        2.times do
          test_pin_go(:high)
          sleep 1.millis
          test_pin_go(:low)
          sleep 1.millis
        end

        test_pin_go(:high)
        sleep 1.millis
        reset_pin_go(:high)
        sleep 1.millis
        test_pin_go :low
        sleep 50.millis # Give microcontroller time to enter BSL

        logger.info 'OK, BSL ready'
      end

      def negate_pin(value)
        raise ArgumentError, "value must be Numeric (0,1)" unless value.is_a?(Numeric)

        value == 1 ? 0 : 1
      end

      def reset_pin_go(value)
        serial_port.dtr = convert_pin value, negate: true
      end

      def test_pin_go(value)
        serial_port.rts = convert_pin value, negate: true
      end
    end
  end
end
