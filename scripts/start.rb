SCREENWIDTH = 512
SCREENHEIGHT = 384
Graphics.resize_screen(SCREENWIDTH, SCREENHEIGHT)

files = Dir.glob(File.join('.', '**', '*.rb')).map { |f| File.expand_path(f) }
files.sort.each { |f| Kernel.send(:require, f) }
abort