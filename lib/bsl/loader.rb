# frozen_string_literal: true

module Bsl
  class Loader

    attr_reader :device_path, :file_path, :check, :verbose
    attr_reader :bsl

    def initialize(opts)
      @device_path = opts.fetch :device
      @file_path = opts.fetch :file
      @check = opts.fetch :check
      @verbose = opts.fetch :verbose

      @bsl = Connection.new @file_path, @verbose
    end

    def prepare
      bsl.mass_erase
    end
  end
end
