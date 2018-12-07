# General utilities related to loading and saving files.
module FileUtils
  module_function

  # Loads and decompressed data from a file.
  # @param filename [String] the path of the file to load.
  # @return [Object] the object that was saved to the file.
  def load_data(filename)
    return File.open(filename, 'rb') do |f|
      next Marshal.load(Zlib::Inflate.inflate(Marshal.load(f)).reverse)
    end
  end

  # Saves and compresses data to a file.
  # @param filename [String] the path to the file the data will be stored in.
  def save_data(filename, data)
    f = File.new(filename, 'wb')
    Marshal.dump(Zlib::Deflate.deflate(Marshal.dump(data).reverse), f)
    f.close
  end
end