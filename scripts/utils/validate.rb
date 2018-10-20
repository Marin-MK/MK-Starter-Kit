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
  raise ArugmentError, "Invalid argument passed to method.\n\n" + errors.compact.join(", ")
end

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
  raise ArgumentError, errors.compact.join(", ")
end