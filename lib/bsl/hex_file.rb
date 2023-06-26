module Bsl
  class HexFile

    attr_reader :path, :raw_data

    def initialize(path)
      @path = File.expand_path path
      @raw_data = File.read path
    end

    def lines
      return @lines if @lines

      @lines = []
      raw_data.each_line { |line| @lines << HexLine.new(line) }
      @lines
    end
  end
end