# frozen_string_literal: true

module Msp430Bsl
  class Response

    class << self
      def supports_kind?(kind)
        Configs::CMD_KINDS.values.map { |val| val[:code] }.include? kind
      end
    end

    attr_reader :kind, :data, :errors

    def initialize(payload)
      raise ArgumentError, 'payload must be an Array' unless payload.is_a?(Array)

      @kind = payload[0]
      raise Exceptions::Response::KindNotSupported, kind unless self.class.supports_kind?(kind)

      @data = payload[1..-1]

      if is_data?
        raise Exceptions::Response::WrongDataSize.new(data, Configs::CMD_KINDS[:data][:payload_min_size]) if data.size < Configs::CMD_KINDS[:data][:payload_min_size]
      else
        raise Exceptions::Response::WrongDataSize.new(data, Configs::CMD_KINDS[:message][:payload_size]) if data.size != Configs::CMD_KINDS[:message][:payload_size]
      end
    end

    def is_data?
      kind == Configs::CMD_KINDS[:data]
    end

    def is_message?
      kind == Configs::CMD_KINDS[:message][:code]
    end

    def is_ok_given_command?(command)
      @errors = []

      # Verify if response kind is compatible with sent command
      unless kind == command.configs[:response][:kind]
        @errors << [:kind, "Kind NOK. Expected response kind: 0x#{command.configs[:response][:kind].to_hex_str} - got: 0x#{kind.to_hex_str}"]
      end
      # Check response exact data size
      if command.configs.has_key?(:data_size) && data.size != command.configs[:data_size]
        @errors << [:data_size, "Data size NOK. Expected data size to be exactly '#{command.configs[:data_size]}' bytes, got '#{data.size}' bytes"]
      end
      # Check response min data size
      if command.configs.has_key?(:data_size_min) && data.size < command.configs[:data_size_min]
        @errors << [:data_size_min, "Min data size NOK. Expected data to have at least a size of '#{command.configs[:min_data_size]}' bytes, got '#{data.size}' bytes"]
      end
      # If kind is "message" check response code
      if is_message?
        success_code = Configs::RESPONSE_MESSAGES[:success][:code]
        if data[0] != success_code  # First (and only) data byte is message code
          @errors << [:message_code, "Message code NOK. Expected message code '#{success_code}', got '#{data[0]}'"]
        end
      end

      @errors.empty?
    end
  end
end
