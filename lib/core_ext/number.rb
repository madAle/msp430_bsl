class Numeric
  def to_hex_str
    n = to_s(16).upcase
    if n.length.odd?
      n = "0#{n}"
    end
    n
  end

  def millis
    self / 1_000.0
  end
end
