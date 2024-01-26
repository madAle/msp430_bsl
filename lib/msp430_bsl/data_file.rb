module Msp430Bsl
  class DataFile

    LINE_DATA_SIZE = 250.freeze

    attr_reader :path, :raw_data, :lines

    def initialize(path = nil)
      @lines = []
      if path
        @path = File.expand_path path
        @raw_data = File.read path
        load_lines
      end
    end

    def add_new_lines_from(data, starting_addr)
      curr_addr = starting_addr
      data.each_slice(line_data_size) do |slice|
        @lines << new_line_from(slice, curr_addr)
        curr_addr += line_data_size
      end
    end

    def <<(line)
      @lines << line
    end

    def line_data_size
      self.class::LINE_DATA_SIZE
    end

    def new_line_from(data, addr, type: :data)
      raise NotImplementedError, 'You must implement this method in a subclass'
    end

    private

    def load_lines
      @raw_data.each_line.with_index do |line, i|
        line.strip!
        next if line.empty?

        @lines << HexLine.new(line, num: i)
      end
    end
  end
end
