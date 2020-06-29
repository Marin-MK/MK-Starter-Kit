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

Font.default_folder = "fonts"
Font.default_name = "fire_red"
Font.default_size = 32

def memory_test(loops = 3, iterations = 100, &block)
  print "====================\nSTART MEMORY REPORT\n====================\n\n"
  loops.times do |i|
    print "Starting iteration #{i + 1}.\n"
    iterations.times(&block)
    print "Iteration #{i + 1} complete.\n"
    Graphics.wait(Graphics.frame_rate * 3) if i != loops - 1
  end
end

#begin
start_game
abort
#rescue #RGSSReset
#  raise "Unimplemented F12 functionality OR ERROR"
#end

$vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
$s = Sprite.new($vp)
$s.bitmap = Bitmap.new(Graphics.width, Graphics.height)

def perform_test
  c1 = Color.new(255, 255, 255)
  c2 = Color.new(255, 0, 0)
  c3 = Color.new(0, 255, 0)
  c4 = Color.new(0, 0, 255)
  c5 = Color.new(0, 0, 0)
  #s = Sprite.new($vp)
  #s.bitmap = Bitmap.new("D:/Desktop/MK/misc/images/logo")
  #s.bitmap.autolock = false
  #s.bitmap.unlock
  #s.bitmap.fill_rect(0, 0, 50, 50, Color.new(255, 0, 0))
  #s.bitmap.draw_line(0, 0, 49, 49, Color.new(rand(255), rand(255), rand(255)))
  #s.bitmap.draw_line(49, 0, 0, 49, Color.new(rand(255), rand(255), rand(255)))
  #s.bitmap.draw_rect(0, 0, 50, 50, Color.new(rand(255), rand(255), rand(255)))
  #s.bitmap.blt(0, s.bitmap.height - 50, s.bitmap, Rect.new(0, 0, 50, 50))
  #s.bitmap.blt(s.bitmap.width - 50, 0, s.bitmap, Rect.new(0, 0, 50, 50))
  #s.bitmap.blt(s.bitmap.width - 50, s.bitmap.height - 50, s.bitmap, Rect.new(0, 0, 50, 50))
  #s.bitmap.font.color.blue = 0
  #s.bitmap.font.outline = true
  #s.bitmap.font.outline_color = Color.new(rand(255), rand(255), rand(255))
  #r = $s.bitmap.text_size("Hello world!")
  #$s.bitmap.draw_text($s.bitmap.width / 2, 0, r.width, r.height, "Hello world!", 1)
  #s.bitmap.lock
  #s.src_rect.x = 10
  #s.src_rect.y = 10
  #s.src_rect.width = s.bitmap.width - 20
  #s.src_rect.height = s.bitmap.height - 20
  #s.x = Graphics.width / 2
  #s.y = Graphics.height / 2
  #s.ox = s.src_rect.width / 2
  #s.oy = s.src_rect.height / 2
  #s.dispose
  #s.opacity = 128
  #s.angle = 45
end

#peform_test

#loop do
#  Graphics.update
#  abort if Input.trigger?(Input::CTRL)
#end

loop do
  for i in 0...99
    perform_test
  end

  GC.start

  t = Time.now
  while Time.now - t < 3
    print (Time.now - t).to_s + "\n"
  end
end
