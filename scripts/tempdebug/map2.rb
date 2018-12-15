map = MKD::Map.new(2)
map.name = "Some Town"
map.width = 7
map.height = 7
map.tilesets = [1, 1]
map.tiles = [[]]
for i in 0...map.width * map.height
  map.tiles[0] << [0, i % 2 == 0 ? 6 : 1]
end
map.save
