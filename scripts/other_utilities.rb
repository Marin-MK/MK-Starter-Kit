class Numeric
  def to_digits(n = 3)
    str = self.to_s
    return str if str.size >= n
    (n - str.size).times { str = "0" + str }
    return str
  end
end

def validate(hash)
  errors = hash.map do |key, value|
    if value.is_a?(Array)
      "Expected #{key} to be one of [#{value.join(",")}], got #{key.class}" unless value.include?(key.class)
    elsif value.is_a?(Symbol)
      "Expected #{key} to respond_to #{value}" unless key.respond_to?(value)
    else
      "Expected #{key} to be a #{value}, got #{key.class}" unless key.is_a?(value)
    end
  end

  return if errors.none?
  raise ArgumentError, errors.compact.join(", ")
end
