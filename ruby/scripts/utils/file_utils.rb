# General additional utilities related to loading and saving files.
module FileUtils
  module_function

  # Loads data from a file.
  # @param filename [String] the file path.
  # @return [Object] the object that was loaded from the file.
  def load_data(filename)
    f = File.open(filename, 'rb')
    begin
      data = YAML.load(f.read)
    rescue
      raise "Invalid MKD file - #{filename}\n\nFile cannot be parsed by YAML."
    end
    f.close
    errmsg = nil
    validate_mkd(data, filename)
    return data[:data]
  end

  # Saves data to a file.
  # @param filename [String] the file path.
  # @param type [Symbol] the type of data to save to the file.
  # @param data [Object] the object to save to the file.
  def save_data(filename, type, data)
    f = File.new(filename, 'wb')
    f.write YAML.dump({type: type, data: data})
    f.close
    return nil
  end
end
