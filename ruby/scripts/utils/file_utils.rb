# Converts a JSON hash to an object
def deserialize_json_object(object)
  return deserialize_json_hash(object) if object.is_a?(Hash)
  if object.is_a?(Array)
    return object.map { |o| deserialize_json_object(o) }
  end
  object = object.sub(/:/,"").to_sym if object.is_a?(String) && object[0] == ':'
  return object
end

# Converts a JSON hash to an object or hash
def deserialize_json_hash(hash)
  if hash.has_key?("^c") # Is actually an object
    klass = Object.const_get(hash["^c"])
    object = klass.allocate
    hash.each do |key, value|
      next if key == "^c"
      object.instance_variable_set(key, deserialize_json_object(value))
    end
    return object
  else # Normal hash
    hash.keys.each do |key|
      oldkey = key
      if key[0] == '[' && key[-1] == ']'
        key = JSON.parse(key)
      elsif key[0] == ':'
        key = key.sub(/:/,"").to_sym
      end
      hash[key] = deserialize_json_object(hash[oldkey])
      if key != oldkey
        hash.delete(oldkey)
      end
    end
    return hash
  end
end

# General additional utilities related to loading and saving files.
module FileUtils
  module_function

  # Loads data from a file.
  # @param filename [String] the file path.
  # @return [Object] the object that was loaded from the file.
  def load_data(filename, type)
    data = File.open(filename, 'rb') do |f|
      next f.read
    end
    data = deserialize_json_object(JSON.parse(data))
    validate_mkd(data, type, filename)
    return data[:data]
  end

  # Saves data to a file.
  # @param filename [String] the file path.
  # @param type [Symbol] the type of data to save to the file.
  # @param data [Object] the object to save to the file.
  def save_data(filename, type, data)
    f2 = File.new(filename, 'wb')
    f2.write ({type: type, data: data}).replace_symbols.to_json
    f2.close
    return nil
  end
end
