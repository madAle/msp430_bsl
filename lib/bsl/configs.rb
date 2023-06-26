# frozen_string_literal: true

module Bsl
  module Configs
    CMD_KINDS = {
      data: { code: 0x3A, payload_min_size: 2 },
      message: { code: 0x3B, payload_size: 1 }
    }.freeze

    CMDS = {
      rx_data_block:      { code: 0x10, requires_addr: true, requires_data: true,     response: { kind: CMD_KINDS[:message][:code], data_size: 1 }},
      rx_data_block_fast: { code: 0x1B, requires_addr: true, requires_data: true,     response: { kind: nil, data_size: 1 }},
      rx_password:        { code: 0x11, requires_addr: false, requires_data: true,    response: { kind: CMD_KINDS[:message][:code], data_size: 1 }},
      erase_segment:      { code: 0x12, requires_addr: true, requires_data: false,    response: { kind: CMD_KINDS[:message][:code], data_size: 1 }},
      lock_unlock_info:   { code: 0x13, requires_addr: false , requires_data: false,  response: { kind: CMD_KINDS[:message][:code], data_size: 1 }},
      reserved:           { code: 0x14, requires_addr: false , requires_data: false,  response: { kind: CMD_KINDS[:message][:code], data_size: 1 }},
      mass_erase:         { code: 0x15, requires_addr: false , requires_data: false,  response: { kind: CMD_KINDS[:message][:code], data_size: 1 }},
      crc_check:          { code: 0x16, requires_addr: true , requires_data: true,    response: { kind: CMD_KINDS[:data][:code], data_size: 2 }},
      load_pc:            { code: 0x17, requires_addr: true, requires_data: false,    response: { kind: CMD_KINDS[:message][:code], data_size: 1 }},
      tx_data_block:      { code: 0x18, requires_addr: true, requires_data: true,     response: { kind: CMD_KINDS[:data][:code], data_size_min: 1 }},
      tx_bsl_version:     { code: 0x19, requires_addr: false , requires_data: false,  response: { kind: CMD_KINDS[:data][:code], data_size: 4 }},
      tx_buffer_size:     { code: 0x1A, requires_addr: false , requires_data: false,  response: { kind: CMD_KINDS[:data][:code], data_size: 2 }},
      change_baud_rate:   { code: 0x52, requires_addr: false , requires_data: true,   response: { kind: nil }}
    }

    RESPONSE_MESSAGES = {
      success:                  { code: 0x00, reason: 'Operation Successful' },
      flash_write_check_failed: { code: 0x01, reason: 'Flash Write Check Failed. After programming, a CRC is run on the programmed data. If the CRC does not match the expected result, this error is returned' },
      flash_fail_bit_set:       { code: 0x02, reason: "Flash Fail Bit Set. An operation set the FAIL bit in the flash controller (see the MSP430F5xx and MSP430F6xx Family User's Guide for more details on the flash fail bit)" },
      voltage_changed:          { code: 0x03, reason: "Voltage Change During Program. The VPE was set during the requested write operation (see the MSP430F5xx and MSP430F6xx Family User's Guide for more details on the VPE bit)" },
      bsl_locked:               { code: 0x04, reason: 'BSL Locked. The correct password has not yet been supplied to unlock the BSL' },
      bsl_password_error:       { code: 0x05, reason: 'BSL Password Error. An incorrect password was supplied to the BSL when attempting an unlock' },
      byte_write_forbidden:     { code: 0x06, reason: 'Byte Write Forbidden. This error is returned when a byte write is attempted in a flash area' },
      unknown_command:          { code: 0x07, reason: 'Unknown Command. The command given to the BSL was not recognized.' },
      packet_too_large:         { code: 0x08, reason: 'Packet Length Exceeds Buffer Size. The supplied packet length value is too large to be held in the BSL receive buffer' }
    }

    CMD_RX_PASSWORD = Array.new(32) { 0xFF }

    BAUD_RATES = {
      9600 => 0x02,
      19200 => 0x03,
      38400 => 0x04,
      57600 => 0x05,
      115200 => 0x06
    }.freeze
  end
end