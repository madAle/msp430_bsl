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
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'http', '>= 4.4', '<= 5.1'
end
