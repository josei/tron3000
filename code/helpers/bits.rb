class Fixnum
  def bits
    n = self; b = -1
    while n > 0
      n >>= 1
      b += 1
    end
    b
  end
end
