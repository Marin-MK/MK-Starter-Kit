require 'rubygems'
require 'yaml'

class Encoding
  unless const_defined?(:ASCII_8BIT)
    ASCII_8BIT = list.select { |enc| enc.name =~ /ASCII-8bit/i }.first || "ASCII-8BIT"
  end
end
