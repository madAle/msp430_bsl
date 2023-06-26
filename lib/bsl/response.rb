# frozen_string_literal: true

module Bsl
  class Response
    class << self
      def supports_kind?(kind)
        Configs::CMD_KINDS.values.include? kind
      end

      def supported_cmds
        Configs::CMDS.keys
      end

      def from(payload)
        raise ArgumentError, 'payload must be an Array' unless payload.is_a?(Array)

        kind = payload[0]
        raise Exceptions::Response::KindNotSupported, kind unless supports_kind?(kind)

        data = payload[1..-1]

        if is_data?(kind)
          ResponseKinds::Data.new data
        else
          ResponseKinds::Message.new data
        end
      end

      def is_data?(kind)
        kind == Configs::CMD_KINDS[:data]
      end

      def is_message?(kind)
        kind == Configs::CMD_KINDS[:message]
      end
    end
  end
end
