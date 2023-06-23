# frozen_string_literal: true

module Bsl
  module Configs
    CMD_KIND_DATA = 0x3A.freeze
    CMD_KIND_MESSAGE = 0x3B.freeze

    CMDS = {
      rx_data_block:      { code: 0x10, requires_addr: true, requires_data: true,     response: { kind: CMD_KIND_MESSAGE }},
      rx_data_block_fast: { code: 0x1B, requires_addr: true, requires_data: true,     response: { kind: CMD_KIND_MESSAGE }},
      rx_password:        { code: 0x11, requires_addr: false, requires_data: true,    response: { kind: CMD_KIND_MESSAGE }},
      erase_segment:      { code: 0x12, requires_addr: true, requires_data: false,    response: { kind: CMD_KIND_MESSAGE }},
      lock_unlock_info:   { code: 0x13, requires_addr: false , requires_data: false,  response: { kind: CMD_KIND_MESSAGE }},
      reserved:           { code: 0x14, requires_addr: false , requires_data: false,  response: { kind: CMD_KIND_MESSAGE }},
      mass_erase:         { code: 0x15, requires_addr: false , requires_data: false,  response: { kind: CMD_KIND_MESSAGE }},
      crc_check:          { code: 0x16, requires_addr: true , requires_data: true,    response: { kind: CMD_KIND_DATA, reason: 'CRC value received' }},
      load_pc:            { code: 0x17, requires_addr: true, requires_data: false,    response: { kind: CMD_KIND_MESSAGE }},
      tx_data_block:      { code: 0x18, requires_addr: true, requires_data: true,     response: { kind: CMD_KIND_DATA, reason: 'Data block received' }},
      tx_bsl_version:     { code: 0x19, requires_addr: false , requires_data: false,  response: { kind: CMD_KIND_DATA, reason: 'Bsl Version received' }},
      tx_buffer_size:     { code: 0x1A, requires_addr: false , requires_data: fals,   response: { kind: CMD_KIND_DAT, reason: 'Buffer size received' }}
    }

    RESPONSE_MESSAGES = {
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
  end
end