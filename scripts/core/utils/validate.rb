# Ensures the given keys have the same data type as their value. Raises an error if invalid.
# @param hash [Hash] the values to validate.
def validate(hash)
  errors = hash.map do |key, value|
    if value.is_a?(Array)
      next "Expected #{key} to be one of [#{value.join(", ")}], but got #{key.class}." unless value.any? { |c| key.is_a?(c) }
    elsif value.is_a?(Symbol)
      next "Expected #{key} to respond_to #{value}." unless key.respond_to?(value)
    else
      if !key.is_a?(value)
        next "Expected #{key} to be a #{value}, but got #{key.class}." unless key.is_a?(Integer) && value == Float
      end
    end
  end
  return if errors.none?
  raise ArgumentError, "Invalid argument passed to method.\n\n" + errors.compact.join(", ")
end

# Ensures the given keys (variable names, not values like in #validate) have the same data as their value. Raises an error if invalid.
# @param input_binding [Binding] a scope's binding to look up local variables with.
# @param hash [Hash] the values to validate.
def validate_binding(input_binding, **hash)
  errors = hash.map do |lv_name, value|
    if input_binding.local_variable_defined?(lv_name)
      key = input_binding.local_variable_get(lv_name)
      if value.is_a?(Array)
        next "Expected `#{lv_name}` to be one of [#{value.join(", ")}], but got #{key.class}." unless value.any? { |c| key.is_a?(c) }
      elsif value.is_a?(Symbol)
        next "Expected `#{lv_name}` (#{key}) to respond_to #{value}." unless key.respond_to?(value)
      else
        if !key.is_a?(value)
          next "Expected #{lv_name} to be a #{value}, but got #{key.class}." unless key.is_a?(Integer) && value == Float
        end
      end
    else
      "Expected the `#{lv_name}` argument to be defined, did you miss-use validate_binding?"
    end
  end
  return if errors.none?
  raise ArgumentError, errors.compact.join(", ")
end

# Ensures the direction is a symbol or a valid Integer. Raises an error if invalid.
# @param dir [Symbol, Integer] the direction to validate.
# @return [Integer] the numeric direction value.
def validate_direction(dir)
  if dir.is_a?(Symbol)
    if [:down,:left,:right,:up].include?(dir)
      dir = ([:down,:left,:right,:up].index(dir) + 1) * 2
    else
      raise "Invalid direction value #{dir.inspect}"
    end
  elsif !dir.is_a?(Integer) || (dir.is_a?(Integer) && dir < 1 || dir > 9)
    raise "Invalid direction value #{dir}"
  end
  return dir
end

def validate_array(hash)
  errors = hash.map do |key, value|
    validate key => Array
    suberrors = key.map do |e|
      if value.is_a?(Array)
        next "Expected #{key} to contain elements of [#{value.join(", ")}], but got #{e.class}." unless value.any? { |c| e.is_a?(c) }
      elsif value.is_a?(Symbol)
        next "Expected #{key} to contain elements that respond_to #{value}." unless e.respond_to?(value)
      else
        if !e.is_a?(value)
          next "Expected #{key} to be a #{value}, but got #{key.class}." unless e.is_a?(Integer) && value == Float
        end
      end
    end
    next if suberrors.none?
    next suberrors.find { |e| !e.nil? }
  end
  return if errors.none?
  raise ArgumentError, "Invalid argument passed to method.\n\n" + errors.compact.join(", ")
end

def validate_mkd(data, type, filename = nil)
  errmsg = nil
  if !data.is_a?(Hash)
    errmsg = "File content is not a Hash."
  elsif !data[:type]
    errmsg = "File content does not contain a type header key."
  elsif !data[:data]
    errmsg = "File content does not contain a data header key."
  elsif data[:type] != type && !type.nil?
    errmsg = "Expected a file of type '#{type}' but got '#{data[:type]}'"
  end
  if errmsg
    raise "Invalid MKD file#{filename ? " - #{filename}" : "."}\n\n" + errmsg
  end
end
