#!/usr/bin/env ruby

require 'slop'
require_relative '../lib/msp430_bsl'

# Force sync on STDOUT write. This way the logger flushes its output after every write
STDOUT.sync = true

include Msp430Bsl::Utils

MAX_WRITE_ATTEMPTS = 3
SUPPORTED_OUTPUT_FORMATS = %w(hex)

@opts = {}
begin
  @opts = Slop.parse help: true do |o|
    o.string '-d', '--device', 'Mandatory: Path to serial programmer device', required: true
    o.string '-o', '--outfile', 'Path to file where to save memory content. Default STDOUT', required: false
    o.string '-g', '--logfile', 'Path to logfile'
    o.integer '-s', '--startaddr', "Memory's starting address to read from. Defaults to 0x8000", default: 0x8000
    o.integer '-e', '--endaddr', "Memory's last address to read. Defaults to 0xFFFF", default: 0xFFFF
    o.string '-l', '--loglevel', "Logger level. One of ['fatal', 'error', 'warn', 'info', 'debug']. Default: 'debug'", default: :debug
    o.string '-f', '--format', "Format of output. Supported formats: [hex]. Default 'hex' (Intel hex)", default: 'hex'
    o.integer '-b', '--baud', 'BAUD rate with which communicate to BSL. Default: 115200', default: 115200
    o.bool '-h', '--help', 'Print this help' do
      puts "#{o}\n"
      exit
    end
  end
rescue Slop::MissingArgument => e
  puts "Error: #{e}. Maybe you specified an empty argument?"
  exit
rescue Slop::UnknownOption => e
  puts "Error: #{e}"
  exit
end

def logger
  @logger ||= build_logger_from @opts
end

def outfile
  @outfile ||= if @opts[:outfile]
                 File.open(@opts[:outfile], 'w')
               else
                 STDOUT
               end
end

unless SUPPORTED_OUTPUT_FORMATS.include? @opts[:format]
  logger.error "File format '#{@opts[:format]} is not supported. Supported formats: #{SUPPORTED_OUTPUT_FORMATS.join ','}'"
  exit 1
end

unless Msp430Bsl::Configs::BAUD_RATES.include? @opts[:baud]
  logger.error "BAUD rate #{@opts[:baud]} not supported. Available BAUD rates: #{ Msp430Bsl::Configs::BAUD_RATES.join ', ' }"
  exit 2
end

# Build UART Connection
@board = Msp430Bsl::Uart::Connection.new @opts[:device], logger: logger

# Enter BSL
@board.enter_bsl
logger.info "Unlocking BSL's password protected commands"
@board.send_command :rx_password, data: Msp430Bsl::Configs::CMD_RX_PASSWORD
# Switch UART to max speed
logger.info "Changing UART BAUD to #{@opts[:baud]}"
@board.send_command :change_baud_rate, data: Msp430Bsl::Configs::BAUD_RATES[@opts[:baud]]
@board.set_uart_speed @opts[:baud]


data = @board.send_command :tx_data_block, addr: @opts[:startaddr], data: [0x10, 0x00]


exit

# Group lines by contiguous memory addr
logger.info 'Writing data to FLASH'
line_groups = hexfile.data_lines_grouped_by_contiguous_addr

def write_data_packet(lines_packet, check: true)
  attempts = 0
  loop do
    # Write data to FLASH
    resp = @board.send_command :rx_data_block, addr: lines_packet.first.addr, data: lines_packet.map { |line| line.data }.reduce(:+)

    break resp unless check
    # Check written data
    data = lines_packet.map { |line| line.data }.flatten
    start_addr = lines_packet.first.addr
    data_len = data.size
    our_crc = crc16(data)

    resp = @board.send_command :crc_check, addr: start_addr, data: [data_len & 0xFF, (data_len >> 8) & 0xFF]
    bsl_crc = resp.data[0] | resp.data[1] << 8

    break resp if our_crc == bsl_crc

    attempts += 1

    logger.error "CRC mismatch at addr '0x#{start_addr.to_hex_str}' - Trying again"

    if attempts >= MAX_WRITE_ATTEMPTS
      logger.fatal "Tried #{attempts} times to write data at addr: 0x#{start_addr.to_hex_str}, but CRC keeps mismatching. Exiting"
      exit
    end
  end
end

# Try to optimize BSL writes
# For each lines group, append as many lines as possible, given the BSL Core Commands buffer size
line_groups.each do |group|
  curr_data_packet = []
  curr_data_size = 0
  # Cycle lines in a group
  group.each do |line|
    if curr_data_packet.empty?
      # Use current line's addr as packet addr
      curr_data_packet << line
      curr_data_size += line.data_length + Msp430Bsl::Uart::PeripheralInterface::TOTAL_SIZE
    elsif (curr_data_size + line.data_length) <= Msp430Bsl::Uart::Connection::CORE_COMMANDS_BUFFER_SIZE
      # If there's still room, append the line data
      curr_data_packet << line
      curr_data_size += line.data_length
    else
      # No room left, send packet
      write_data_packet curr_data_packet, check: @opts[:check]
      curr_data_packet = []
      curr_data_size = 0
      redo  # Handle current line than would otherwise be skipped
    end
  end

  # Send residual lines before handling next group
  if curr_data_packet.any?
    write_data_packet curr_data_packet, check: @opts[:check]
  end
end

# Reset board if requested to
if @opts[:reset]
  logger.info "Resetting board"
  @board.trigger_reset
end
logger.info 'Closing connection'
@board.close_connection
logger.info 'Upload done!'
