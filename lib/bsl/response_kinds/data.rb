module Bsl
  module ResponseKinds
    class Data

      PAYLOAD_MIN_SIZE = 2.freeze  # 1 byte for the KIND and min 1 byte for the MESSAGE

      attr_reader :data

      def initialize(payload)
        raise Exceptions::Response::WrongDataSize.new(payload, PAYLOAD_MIN_SIZE, min: true) if payload.size < PAYLOAD_MIN_SIZE

        @data = payload
      end

      def is_ok_given_command?(command)
        @errors = []

        cmd_configs = Configs::CMD[command.name]
        unless kind == cmd_configs[:response][:kind]
          @errors << [:kind, "Kind NOK. Expected response kind: #{cmd_configs[:response][:kind]} - got: #{kind}"]
        end

        if cmd_configs.has_key?(:data_size) && data.size != cmd_configs[:data_size]
          @errors << [:data_size, "Data size NOK. Expected data size to be '#{cmd_configs[:data_size]}', got '#{data.size}'"]
        end

        if cmd_configs.has_key?(:data_size_min) && data.size < cmd_configs[:data_size_min]
          @errors << [:data_size_min, "Min data size NOK. Expected data to have at least a size of '#{cmd_configs[:min_data_size]}', got '#{data.size}'"]
        end

        @errors.empty?
      end
    end
  end
end
