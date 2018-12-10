SCREENWIDTH = 480
SCREENHEIGHT = 320
Graphics.resize_screen(SCREENWIDTH, SCREENHEIGHT)

scripts = File.open('scripts/_order.rb').read
scripts.each_line do |line|
  file, *name = line.split(':')
  name = name.join(' ').strip.chomp
  Kernel.send(:require, File.expand_path("scripts/#{file}"))
end

abort
