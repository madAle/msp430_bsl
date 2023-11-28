module Msp430Bsl
  class HexFile

    attr_reader :path, :raw_data, :lines

    def initialize(path = nil)
      @lines = []
      if path
        @path = File.expand_path path
        @raw_data = File.read path
        load_lines
      end
    end

    def <<(line)
      @lines << line
    end

    def data_lines_grouped_by_contiguous_addr
      return @grouped_lines if @grouped_lines

      @grouped_lines = []
      curr_group = nil
      curr_addr = nil
      prev_line = nil
      lines.each do |line|
        next unless line.is_of_type? :data

        if curr_addr.nil?
          # We just started a new group
          curr_addr = line.addr
          curr_group = [line]
        elsif line.has_addr_contiguous_to? prev_line
          # We already have a current group
          curr_group << line
          curr_addr = line.addr
        else
          @grouped_lines << curr_group
          curr_addr = nil
          redo
        end

        prev_line = line
      end

      @grouped_lines << curr_group if curr_group.any?

      @grouped_lines
    end

    def to_s
      @lines.map(&:to_s).join("\n")
    end

    private

    def load_lines
      raw_data.each_line.with_index { |line, i| @lines << HexLine.new(line, num: i) }
    end
  end
end
