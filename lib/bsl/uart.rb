# frozen_string_literal: true

module Bsl
  class Uart

    CONFIGS = {
      low_speed: { baud: 9600, data_bits: 8, stop_bits: 1, parity: SerialPort::EVEN },
      high_speed: { baud: 57600, data_bits: 8, stop_bits: 1, parity: SerialPort::EVEN }
    }.freeze

    attr_reader :serial_port, :device_path, :logger

    def initialize(device_path, opts = {})
      @device_path = device_path
      @logger = opts.fetch :logger, Logger.new(STDOUT)

      @serial_port = SerialPort.new @device_path
    end

    def invoke_bsl
      logger.info 'Entering BSL...'
      reset_pin :high
      test_pin :high
      sleep_millis 250
      reset_pin :low
      sleep_millis 10
      test_pin :high
      sleep_millis 10
      test_pin :low
      sleep_millis 10
      test_pin :high
      sleep_millis 10
      test_pin :low
      sleep_millis 10
      test_pin :high
      sleep_millis 10
      test_pin :low
      sleep_millis 10
      reset_pin :high
      sleep_millis 10
      test_pin :high
      sleep_millis 250
      logger.info 'OK, BSL ready'
    end

    def set_high_speed
      serial_port.set_modem_params *CONFIGS[:high_speed]
      serial_port.rts = true
      serial_port.dtr = false
    end

    def set_low_speed
      serial_port.set_modem_params *CONFIGS[:low_speed]
    end

    private

    def negate(value)
      case value
      when Symbol
        value == :high ? 0 : 1  # dtr must be negated
      when Numeric
        value == 1 ? 0 : 1      # dtr must be negated
      end
    end

    def reset_pin(value)
      serial_port.dtr = negate value
    end

    def sleep_millis_millis(value)
      sleep_millis value/1_000.0
    end

    def sleep_millis_micros(value)
      sleep_millis value/1_000_000.0
    end

    def test_pin(value)
      serial_port.rts = negate value
    end
  end
end
