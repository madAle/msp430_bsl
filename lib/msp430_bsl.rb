require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
core_ext = "#{__dir__}/lib/core_ext/"
loader.ignore core_ext

loader.setup


module Msp430Bsl
end
