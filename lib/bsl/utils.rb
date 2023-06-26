# frozen_string_literal: true
require 'logger'

module Bsl
  module Utils
    def crc16(data)
      raise ArgumentError, 'data must be an Array' unless data.is_a?(Array)

      crc = 0xFFFF

      data.each do |byte|
        x = (crc >> 8 ^ byte) & 0xFF
        x ^= x >> 4
        crc = (crc << 8) ^ (x << 12) ^ (x << 5) ^ x
      end

      crc & 0xFFFF
    end

    def crc8(data)
      (~data.reduce(:+) + 1) & 0xFF
    end

    def build_logger_from(opts)
      logto = if opts[:logfile]
                File.expand_path opts[:logfile]
              else
                STDOUT
              end

      Logger.new logto, level: normalize_log_level(opts[:loglevel])
    end

    def normalize_log_level(level)
      case level
      when :debug, ::Logger::DEBUG, 'debug', 'd' then ::Logger::DEBUG
      when :info,  ::Logger::INFO,  'info', 'i'  then ::Logger::INFO
      when :warn,  ::Logger::WARN,  'warn', 'w'  then ::Logger::WARN
      when :error, ::Logger::ERROR, 'error', 'e' then ::Logger::ERROR
      when :fatal, ::Logger::FATAL, 'fatal', 'f' then ::Logger::FATAL
      else
        ENV['LOG_LEVEL'] || Logger::DEBUG
      end
    end
  end
end
