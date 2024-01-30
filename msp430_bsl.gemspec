lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'msp430_bsl/version'

Gem::Specification.new do |spec|
  spec.name          = 'msp430_bsl'
  spec.version       = Msp430Bsl::VERSION
  spec.authors       = ['Alessandro Verlato']
  spec.email         = ['averlato@gmail.com']

  spec.summary       = %q{Texas Instrument MSP430 BSL Ruby library}
  spec.homepage      = 'https://github.com/madAle/msp430_bsl'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'MIT-LICENSE', 'lib/**/*.rb']
  spec.executables   = ['upload_hex', 'dump_flash']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'zeitwerk', '2.6.8'
  spec.add_dependency 'serialport', '1.3.2'
  spec.add_dependency 'slop', '4.10.1'

  spec.add_development_dependency 'pry', '0.14.2'
end
