# Ensures the given keys have the same data type as their value. Raises an error if invalid.
def validate(hash)
  errors = hash.map do |key, value|
    if value.is_a?(Array)
      "Expected #{key} to be one of [#{value.join(", ")}], but got #{key.class}." unless value.include?(key.class)
    elsif value.is_a?(Symbol)
      "Expected #{key} to respond_to #{value}." unless key.respond_to?(value)
    else
      "Expected #{key} to be a #{value}, but got #{key.class}." unless key.is_a?(value)
    end
  end
  return if errors.none?
  stack = caller.map { |e| "At " + e.gsub!(Dir.pwd + "/scripts/", "") }.join("\n")
  raise ArgumentError, "Invalid argument passed to method.\n\n" + errors.compact.join(", ") + "\n\n" + stack
end

# Ensures the given keys (variable names, not values like in #validate) have the same data as their value. Raises an error if invalid.
# @param input_binding [Binding] a scope's binding to look up local variables with.
def validate_binding(input_binding, **hash)
  errors = hash.map do |lv_name, value|
    if input_binding.local_variable_defined?(lv_name)
      key = input_binding.local_variable_get(lv_name)
      if value.is_a?(Array)
        "Expected `#{lv_name}` to be one of [#{value.join(", ")}], got #{key.class}." unless value.include?(key.class)
      elsif value.is_a?(Symbol)
        "Expected `#{lv_name}` (#{key}) to respond_to #{value}." unless key.respond_to?(value)
      else
        "Expected `#{lv_name}` to be a #{value}, got #{key.class}." unless key.is_a?(value)
      end
    else
      "Expected the `#{lv_name}` argument to be defined, did you miss-use validate_binding?"
    end
  end
  return if errors.none?
  stack = caller.map { |e| "At " + e.gsub!(Dir.pwd + "/scripts/", "") }.join("\n")
  raise ArgumentError, errors.compact.join(", ") + "\n\n" + stack
end

# Ensures the direction is a symbol or a valid Fixnum. Raises an error if invalid.
# @param dir [Symbol, Fixnum] the direction to validate.
# @return [Fixnum] the numeric direction value.
def validate_direction(dir)
  if dir.is_a?(Symbol)
    if [:down,:left,:right,:up].include?(dir)
      dir = ([:down,:left,:right,:up].index(dir) + 1) * 2
    else
      stack = caller.join("\n")
      raise "Invalid direction value #{dir.inspect}\n\n#{stack}"
    end
  elsif !dir.is_a?(Fixnum) || (dir.is_a?(Fixnum) && dir < 1 || dir > 9)
    stack = caller.map { |e| "At " + e.gsub(Dir.pwd + "/scripts/", "") }.join("\n")
    raise "Invalid direction value #{dir}\n\n#{stack}"
  end
  return dir
end