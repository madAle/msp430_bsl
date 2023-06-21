# frozen_string_literal: true
require 'logger'
require 'timeout'

module Bsl
  class Uart

    CONFIGS = {
      low_speed: { 'baud': 9600, data_bits: 8, stop_bits: 1, parity: SerialPort::EVEN }.transform_keys(&:to_s),
      high_speed: { baud: 57600, data_bits: 8, stop_bits: 1, parity: SerialPort::EVEN }.transform_keys(&:to_s)
    }.freeze

    MAX_READ_TIME = 1.0  # Seconds

    attr_reader :serial_port, :device_path, :logger

    def initialize(device_path, opts = {})
      @device_path = device_path
      @logger = opts.fetch :logger, ::Logger.new(STDOUT)

      @serial_port = SerialPort.new @device_path
    end

    def invoke_bsl
      logger.info 'Entering BSL...'
      # slau319 pag. 5 - Fig. 1-2
      test_pin_go(:low)
      reset_pin_go(:low)
      sleep_ms 5
      2.times do
        test_pin_go(:high)
        sleep_ms 1
        test_pin_go(:low)
        sleep_ms 1
      end

      test_pin_go(:high)
      sleep_ms 1
      reset_pin_go(:high)
      sleep_ms 1
      test_pin_go :low
      sleep_ms 50

      logger.info 'OK, BSL ready'
    end

    def trigger_reset
      # slau319 pag. 5 - Fig. 1-1
      reset_pin_go :low
      test_pin_go :low
      sleep_ms 5
      reset_pin_go :high
    end

    def read
      begin
        res = []
        Timeout::timeout(MAX_READ_TIME) do
          loop do
            read = serial_port.getbyte
            break unless read
            res << read
          end
        end
      rescue Timeout::Error
        raise Bsl::Exception, "No response received from BSL"
      end

      res
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

    def method_missing(method_name, *args)
      serial_port.send method_name, *args
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

    def negate_pin(value)
      raise ArgumentError, "value must be Numeric (0,1)" unless value.is_a?(Numeric)

      value == 1 ? 0 : 1
    end

    def reset_pin_go(value)
      serial_port.dtr = convert_pin value, negate: true
    end

    def sleep_ms(value)
      sleep value / 1_000.0
    end

    def sleep_micros(value)
      sleep value / 1_000_000.0
    end

    def sleep_nanos(value)
      sleep value / 1_000_000_000.0
    end

    def test_pin_go(value)
      serial_port.rts = convert_pin value, negate: true
    end
  end
end
