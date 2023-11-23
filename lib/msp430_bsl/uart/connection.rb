# frozen_string_literal: true
require 'logger'
require 'timeout'

module Msp430Bsl
  module Uart
    class Connection

      UART_CONFIGS = { data_bits: 8, stop_bits: 1, parity: SerialPort::EVEN }.transform_keys(&:to_s).freeze

      WAIT_FOR_ACK_MAX      = 1000.millis
      WAIT_FOR_RESPONSE_MAX = 1000.millis

      attr_reader :serial_port, :device_path, :logger, :cmd_buff_size

      def initialize(device_path, opts = {})
        @device_path = device_path
        @logger = opts.fetch :logger, Logger.new(STDOUT)
        @cmd_buff_size = opts.fetch :cmd_buf_size, Configs::CORE_COMMANDS_BUFFER_SIZE

        @serial_port = SerialPort.new @device_path
        @serial_port.flow_control = SerialPort::NONE
      end

      def close_connection
        serial_port.close
      end

      def check_bsl_reply
        reply.length > 1 && reply[0] == BSL_MESSAGE && reply[1] == BSL_OK
      end

      def enter_bsl
        logger.info "Connecting to target board through UART on #{device_path}"
        set_uart_speed 9600
        invoke_bsl
      end

      def read_response_for(command)
        raise ArgumentError, "an instance of Msp430Bsl::Command is expected as argument. Given: '#{command.class}'" unless command.is_a?(Command)

        # Wait for first response byte - UART's ACK/NACK
        ack = nil
        begin
          Timeout::timeout(WAIT_FOR_ACK_MAX) do
            ack = Ack.new serial_port.getbyte
          end
        rescue Timeout::Error => e
          logger.error 'Timeout occurred while waiting for UART ACK'
          raise e
        end

        # If we arrived here, ack has been populated
        if ack && ack.ok?
          logger.debug "IN  <- ACK (1 byte) 0x#{ack.value.to_hex_str}"
        else
          logger.error ack.reason
          raise Exceptions::Ack::NOK, ack.value
        end

        # If this command has not response, return
        unless command.configs[:response][:kind]
          return ack
        end

        # Wait for command response
        begin
          pi = PeripheralInterface.new
          Timeout::timeout(WAIT_FOR_RESPONSE_MAX) do
            loop do
              read = serial_port.readpartial cmd_buff_size
              pi.push read.unpack 'C*'
              break if pi.valid?
            end
          end
        rescue Timeout::Error => e
          logger.error 'Timeout occurred while fetching response from UART'
          raise e
        end

        # Unwrap PeripheralInterface and create Response
        logger.debug "IN  <- RES (#{pi.packet.size} bytes) #{pi.to_hex_ary_str}"
        response = pi.to_response
        unless response.is_ok_given_command? command
          raise Msp430Bsl::Exceptions::Response::NotValid, response.errors
        end

        response
      end

      def send_command(cmd_name, addr: nil, data: nil, log_only: false)
        command = Command.new cmd_name, addr: addr, data: data
        pi = PeripheralInterface.wrap command
        logger.debug "Sending command '#{command.name}' over UART"
        # Flush serial's output and input before sending a new command
        serial_port.flush_output
        serial_port.flush_input

        unless pi.valid?
          logger.error "PeripheralInterface not valid. Errors: #{pi.errors}"
          return nil
        end

        logger.debug "OUT -> (#{pi.packet.size} bytes) #{pi.to_hex_ary_str}"
        unless log_only
          serial_port.write pi.to_uart
          read_response_for command
        end
      end

      def set_uart_speed(baud)
        raise StandardError, "BAUD not supported. Supported BAUDs: #{Configs::BAUD_RATES.keys}" unless Configs::BAUD_RATES.keys.include?(baud)

        logger.debug "Setting serial port BAUD to #{baud} bps"

        serial_port.set_modem_params UART_CONFIGS.merge('baud' => baud)  # We must use strings as keys
        test_pin_go :high
        reset_pin_go :low
      end

      def trigger_reset
        # slau319af.pdf - pag. 5 - Fig. 1-1
        reset_pin_go :low
        test_pin_go :low
        sleep 5.millis
        reset_pin_go :high
        sleep 5.millis
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
