class String

  def to_hex_ary
    res = []
    chars.each_slice(2) { |byte| res << byte.join().to_i(16) }
    res
  end
end
