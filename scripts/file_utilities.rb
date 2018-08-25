def load_data(filename)
  return File.open(filename, 'rb') do |f|
    next Marshal.load(Zlib::Inflate.inflate(Marshal.load(f)).reverse)
  end
end

def save_data(filename, data)
  f = File.new(filename, 'wb')
  Marshal.dump(Zlib::Deflate.deflate(Marshal.dump(data).reverse), f)
  f.close
  return nil
end