require 'zeitwerk'
require 'serialport'

loader = Zeitwerk::Loader.new
loader.push_dir File.expand_path(__dir__)
core_ext = File.expand_path('core_ext', __dir__)
loader.ignore core_ext
loader.setup

# Require core_ext files
Dir["#{core_ext}/**/*.rb"].each { |file| require file }

module Msp430Bsl
end
