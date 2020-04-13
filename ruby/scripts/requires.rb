require 'rubygems'
require 'json'
require 'fileutils'

class Encoding
  unless const_defined?(:ASCII_8BIT)
    ASCII_8BIT = list.select { |enc| enc.name =~ /ASCII-8bit/i }.first || "ASCII-8BIT"
  end
end

def start_game
  scripts = File.open('data/order.mkd').read
  scripts.each_line do |line|
    file, *name = line.split(':')
    name = name.join(' ').strip.chomp
    require File.expand_path("ruby/scripts/#{file}")
  end
end

begin
  start_game
rescue RGSSReset
  raise "Unimplemented F12 functionality"
end
