module Msp430Bsl
  class RawDataFile < DataFile

    def to_s
      @lines.map { |l| l.to_hex }.join
    end

    def new_line_from(data, addr, type: :data)
      data
    end
  end
end
