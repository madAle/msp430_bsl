module Msp430Bsl
  class HexFile < DataFile

    LINE_DATA_SIZE = 0x10.freeze

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

    def raw_data
      @lines.map { |l| l.data.to_hex }.join("\n")
    end

    def new_line_from(data, addr, type: :data)
      data_str = "#{data.size.to_hex_str}#{addr.to_hex_str}#{HexLine::RECORD_TYPES[type].to_hex_str}#{data.to_hex.join}"
      data_str = ":#{data_str}#{crc8(data_str.to_hex_ary).to_hex_str}"
      HexLine.new data_str
    end

    def to_s
      @lines.map(&:to_s).join("\n")
    end
  end
end
