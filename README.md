# MSP430Bsl

This library is a base for developing MSP430 BSL-based utilities
   
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'msp430_bsl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install msp430_bsl
    
## Compatibility

Although it's not tested, this library should be compatibile with Ruby 2.7.0 or higher.

## Usage

**Help is appreciated to write some good USAGE**

In the `bin` folder there's the `upload_hex` executable. 

TL;DR: the script can upload a .hex file to the target through a normal UART connection (`rts` and `dtr` pins required). 

**The script has been tested only with CC430F5137**

Just run `bin/upload_hex -h` to show available options.

## TODO

* Write specs
* Add documentation
* Write a good Usage
* Add missing features and generalize the ones already present
* Delete this TODO section

## Contributing

**Bug reports and pull requests are welcome!**

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

