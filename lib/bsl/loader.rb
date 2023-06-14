# frozen_string_literal: true

module Bsl
  class Loader

    attr_reader :device_path, :file_path, :check, :verbose
    attr_reader :board

    def initialize(opts)
      @device_path = opts.fetch :device
      @file_path = opts.fetch :file
      @check = opts.fetch :check, true
      @verbose = opts.fetch :verbose, false
      @logger = build_logger_from opts

      @board = Connection.new @file_path, verbose: @verbose, logger: logger
    end

    def prepare_board
      board.enter_bsl
      board.mass_erase_flash
    end

    def build_logger_from(opts)
      logto = if opts[:logfile]
                File.expand_path opts[:logfile]
              else
                STDOUT
              end

      Logger.new logto
    end
  end
end
