# General additional utilities related to loading and saving files.
module FileUtils
  module_function

  # Loads data from a JSON file.
  # @param filename [String] the file path.
  # @return [Object] the object that was loaded from the file.
  def load_data(filename, type = nil, return_everything = false)
    data = File.open(filename, 'rb') do |f|
      next f.read
    end
    json = JSON.parse(data)
    data = deserialize_json_object(json)
    validate_mkd(data, type, filename)
    return return_everything ? data : data[:data]
  end

  # Saves data to a file using JSON.
  # @param filename [String] the file path.
  # @param type [Symbol] the type of data to save to the file.
  # @param data [Object] the object to save to the file.
  def save_data(filename, type, data)
    f2 = File.new(filename, 'wb')
    f2.write JSON.generate(({type: type, data: data}).dump_data.replace_symbols)
    f2.close
    return nil
  end

  # Saves data to a file using Marshal.
  # @param filename [String] the file path.
  # @param type [Symbol] the type of data to save to the file.
  # @param data [Object] the object to save to the file.
  def save_binary_data(filename, type, data)
    f = File.new(filename, 'wb')
    # Dump -> Reverse -> Inflate -> Dump -> Reverse
    f.write Marshal.dump(Zlib::Inflate.inflate(Marshal.dump({type: type, data: data}).reverse)).reverse
    f.close
    return nil
  end

  # Loads data from a Marshal file.
  # @param filename [String] the file path.
  # @return [Object] the object that was loaded from the file.
  def load_binary_data(filename, type = nil, return_everything = false)
    data = File.open(filename, 'rb') do |f|
      next f.read
    end
    # Reverse -> Load -> Deflate -> Reverse -> Load
    json = Marshal.load(Zlib::Deflate.deflate(Marshal.load(data.reverse)).reverse)
    data = deserialize_json_object(json)
    validate_mkd(data, type, filename)
    return return_everything ? data : data[:data]
  end

  # Loads and re-saves all data files.
  def refresh_data_files
    Dir.glob('data/**/*').each do |f|
      next if !File.file?(f) || f == "data/order.mkd" || f[-4..-1] != '.mkd'
      data = FileUtils.load_data(f, nil, true)
      FileUtils.save_data(f, data[:type], data[:data])
    end
  end
end

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
      if object.is_a?(Struct)
        object.set(key.sub(/@/,""), deserialize_json_object(value))
      else
        object.instance_variable_set(key, deserialize_json_object(value))
      end
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
