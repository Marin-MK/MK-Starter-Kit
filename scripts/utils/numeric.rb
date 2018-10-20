class Numeric
  def to_digits(n = 3)
    str = self.to_s
    return str if str.size >= n
    str.prepend("0" * (n - str.size))
    return str
  end
end