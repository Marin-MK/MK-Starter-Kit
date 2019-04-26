SCREENWIDTH = 480
SCREENHEIGHT = 320
Graphics.resize_screen(SCREENWIDTH, SCREENHEIGHT)

$:.push "ruby/extensions"
$:.push "ruby/extensions/i386-mingw32"

scripts = File.open('ruby/scripts/_order.rb').read
scripts.each_line do |line|
  file, *name = line.split(':')
  name = name.join(' ').strip.chomp
  Kernel.send(:require, File.expand_path("ruby/scripts/#{file}"))
end

abort
