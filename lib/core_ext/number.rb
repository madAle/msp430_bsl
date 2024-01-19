class Numeric
  def to_hex_str
    n = to_s(16).upcase
    if n.length.odd?
      n = "0#{n}"
    end
    n
  end

  def to_bytes_ary(le: true, padding: 2)
    res = []
    to_hex_str.chars.each_slice(2) { |byte| res << byte.join().to_i(16) }
    if res.size < padding
      res.prepend Array.new(padding - res.size) { 0 }
      res.flatten!
    end
    if le
      res.reverse!
    end
    res
  end

  def millis
    self / 1_000.0
  end
end
