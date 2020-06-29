require 'rubygems'
require 'json'
require 'fileutils'

def start_game
  scripts = File.open('data/order.mkd').read
  scripts.each_line do |line|
    file, *name = line.split(':')
    name = name.join(' ').strip.chomp
    require File.expand_path("ruby/scripts/#{file}")
  end
end

Font.default_folder = "fonts"
Font.default_name = "fire_red"
Font.default_size = 32

start_game
