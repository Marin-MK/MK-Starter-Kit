class Numeric
  def to_digits(n = 3)
    str = self.to_s
    return str if str.size >= n
    (n - str.size).times { str = "0" + str }
    return str
  end
end

def validate(hash)
  for key in hash.keys
    v = hash[key]
    v = [v] unless v.is_a?(Array)
    match = false
    v.each do |e|
      break if match
      if e.is_a?(Symbol)
        match = true if key.respond_to?(e)
      elsif e.is_a?(Class) || e.is_a?(Module)
        match = true if key.is_a?(e)
      end
    end
    unless match
      types = v.select { |e| e.is_a?(Class) || e.is_a?(Module) }
      meths = v.select { |e| e.is_a?(Symbol) }
      errmsg = "Invalid argument passed to method.\n\nType: #{key.class}\n"
      if types.size > 0
        typestr = ""
        if types.size == 1
          typestr = types[0].to_s
        elsif types.size == 2
          typestr = types[0].to_s + " or " + types[1].to_s
        else
          for i in 0...types.size - 1
            typestr << types[i].to_s + ", "
          end
          typestr << "or " + types.last.to_s
        end
        errmsg << "Expected class: #{typestr}\n"
      end
      if meths.size > 0
        methstr = ""
        if meths.size == 1
          methstr = meths[0].to_s
        elsif meths.size == 2
          methstr = meths[0].to_s + " or " + meths[1].to_s
        else
          for i in 0...meths.size - 1
            methstr << meths[i].to_s + ", "
          end
          methstr << "or " + meths.last.to_s
        end
        errmsg << "Expected method support: #{methstr}\n"
      end
      raise ArgumentError, errmsg
    end
  end
end