class String
  def to_hex_array
    unpack 'C*'
  end
end
