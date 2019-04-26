# General utilities related to loading and saving files.
module FileUtils
  module_function

  # Loads and decompresses data from a file.
  # @param filename [String] the file path.
  # @return [Object] the object that was saved to the file.
  def load_data(filename)
    return File.open(filename, 'rb') do |f|
      next Marshal.load(Zlib::Inflate.inflate(Marshal.load(f)).reverse)
    end
  end

  # Compresses and saves data to a file.
  # @param filename [String] the file path.
  # @param data [Object] the object to save to the file.
  def save_data(filename, data)
    f = File.new(filename, 'wb')
    Marshal.dump(Zlib::Deflate.deflate(Marshal.dump(data).reverse), f)
    f.close
  end
end
