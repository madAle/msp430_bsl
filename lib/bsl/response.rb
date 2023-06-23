# frozen_string_literal: true

module Bsl
  class Response

    PAYLOAD_MIN_SIZE = 2.freeze  # 1 byte for the KIND and min 1 byte for the MESSAGE


    CMD = {
      data_block:   { kind: CMD_DATA, reason: 'Data block received' },
      bsl_version:  { kind: CMD_DATA, reason: 'Bsl Version received' },
      crc_value:    { kind: CMD_DATA, data_size: 2, reason: 'CRC value received' },
      buffer_size:  { kind: CMD_DATA, data_size: 2, reason: 'Buffer size received' },
      success:                  { data_size: 1, code: 0x00, reason: 'Operation Successful' },
      flash_write_check_failed: { data_size: 1, code: 0x01, reason: 'Flash Write Check Failed. After programming, a CRC is run on the programmed data. If the CRC does not match the expected result, this error is returned' },
      flash_fail_bit_set:       { data_size: 1, code: 0x02, reason: "Flash Fail Bit Set. An operation set the FAIL bit in the flash controller (see the MSP430F5xx and MSP430F6xx Family User's Guide for more details on the flash fail bit)" },
      voltage_changed:          { data_size: 1, code: 0x03, reason: "Voltage Change During Program. The VPE was set during the requested write operation (see the MSP430F5xx and MSP430F6xx Family User's Guide for more details on the VPE bit)" },
      bsl_locked:               { data_size: 1, code: 0x04, reason: 'BSL Locked. The correct password has not yet been supplied to unlock the BSL' },
      bsl_password_error:       { data_size: 1, code: 0x05, reason: 'BSL Password Error. An incorrect password was supplied to the BSL when attempting an unlock' },
      byte_write_forbidden:     { data_size: 1, code: 0x06, reason: 'Byte Write Forbidden. This error is returned when a byte write is attempted in a flash area' },
      unknown_command:          { data_size: 1, code: 0x07, reason: 'Unknown Command. The command given to the BSL was not recognized.' },
      packet_too_large:         { data_size: 1, code: 0x08, reason: 'Packet Length Exceeds Buffer Size. The supplied packet length value is too large to be held in the BSL receive buffer' }
    }

    class << self
      def supports_cmd?(cmd)
        CMD.keys.include? cmd
      end

      def supported_cmds
        CMD.keys
      end

      def supports_message?(cmd, message)
        message = message.to_sym
        supported_messages_for_cmd(cmd)[message]
      end

      def supported_messages_for_cmd(cmd)
        raise Exceptions::Response::CMDNotSupported, cmd unless supports_cmd?(cmd)

        CMD[cmd]
      end
    end

    attr_reader :cmd, :expected_msg_name, :message, :code, :data, :errors

    def initialize(payload, expected_message_name = nil)
      raise ArgumentError, 'payload must be an Array' unless payload.is_a?(Array)
      raise Exceptions::Response::NotEnoughData, payload unless payload.size >= PAYLOAD_MIN_SIZE

      @cmd = payload[0]

      raise Exceptions::Response::CMDNotSupported, @cmd unless self.class.supports_cmd?(@cmd)

      if is_data?
      raise Exceptions::Response::MessageNotSupported.new(@cmd, expected_message_name) unless self.class.supports_message?(@cmd, expected_message_name)

      @expected_msg_name = expected_message_name.to_sym
      @message = self.class.supported_messages_for_cmd(@cmd)[@expected_msg_name]

      @data = payload[1..-1]

      if is_message?
        @code = @data.first
      end
    end

    def is_data?
      @cmd == CMD_DATA
    end

    def is_message?
      @cmd == CMD_MESSAGE
    end

    def valid?
      @errors = []

      if @message.has_key?(:data_size) && @data.size != @message[:data_size]
        @errors << [:data_len, "Data size NOK. Expected data size '#{@message[:data_size]}', got '#{@data.size}'"]
      end
      if is_message? && @message[:code] != @code
        @errors << [:message_code, "Message code NOK. Expected message code '#{@message[:code]}', got '#{@code}'"]
      end

      @errors.empty?
    end
  end
end
