require 'bundler/setup'
Bundler.require

loader = Zeitwerk::Loader.new
loader.push_dir 'lib'
core_ext = "#{__dir__}/lib/core_ext/"
loader.ignore core_ext
loader.setup
# Require core_ext files
Dir['./lib/core_ext/**/*.rb'].each { |file| require file }

@board = Bsl::Uart::Connection.new '/dev/tty.usbserial-DA013RBN'

read = Thread.new do
  while true
    b = @board.uart.getbyte
    p [b, b.to_hex_str]
  end
end


@board.enter_bsl

@board.send_command :mass_erase

read.join
