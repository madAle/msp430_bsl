module Bsl
  module ResponseKinds
    class Message

      PAYLOAD_SIZE = 1.freeze

      class << self
        def supports?(message)
          message = message.to_sym
          supported_messages[message]
        end

        def supported_messages
          Configs::RESPONSE_MESSAGES
        end
      end

      attr_reader :code

      def initialize(payload)
        raise Exceptions::Response::WrongDataSize.new(payload, PAYLOAD_SIZE) if payload.size != PAYLOAD_SIZE

        @code = payload.first
      end

      def is_ok_given_command?(command)
        cmd_configs = Configs::RESPONSE_MESSAGES[command.name]

        if cmd_configs.has_key?(:data_size) && data.size != cmd_configs[:data_size]
          @errors << [:data_size, "Data size NOK. Expected data size to be '#{cmd_configs[:data_size]}', got '#{data.size}'"]
        end
        if cmd_configs[:code] != code
          @errors << [:message_code, "Message code NOK. Expected message code '#{cmd_configs[:code]}', got '#{code}'"]
        end

        @errors.empty?
      end
    end
  end
end
