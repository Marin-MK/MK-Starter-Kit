SCREENWIDTH = 480
SCREENHEIGHT = 320
Graphics.resize_screen(SCREENWIDTH, SCREENHEIGHT)

#files = Dir.glob(File.join('.', '**', '*.rb')).map { |f| File.expand_path(f) }
#files.sort.each { |f| Kernel.send(:require, f) }
txt = File.open('scripts/_order.rb') { |f| f.read }
txt.gsub!(/\r/, '')
for e in txt.split("\n")
  file = e.split(':')[0]
  name = e.split(':')[1..-1].join(':')
  name = name[1..-1] while name[0] == ' '
  Kernel.send(:require, File.expand_path("scripts/" + file))
end

abort