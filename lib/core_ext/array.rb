class Array
  def to_hex
    map { |el| el.to_hex_str }
  end

  def to_chr
    map { |el| el.chr }
  end

  def to_chr_string
    to_chr.join
  end
end
