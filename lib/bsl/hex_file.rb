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
      raw_data.each_line.with_index { |line, i| @lines << HexLine.new(line, num: i) }
      @lines
    end

    def data_lines_grouped_by_contiguous_addr
      res = []
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
          res << curr_group
          curr_addr = nil
          redo
        end

        prev_line = line
      end

      res << curr_group if curr_group.any?

      res
    end
  end
end
