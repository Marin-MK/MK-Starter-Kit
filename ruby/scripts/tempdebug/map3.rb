map = MKD::Map.new(3)
map.name = "Bottom Left Map"
map.width = 5
map.height = 5
map.tilesets = [1]
map.tiles = [
  [[0, 113]] * map.width * map.height
]

map.save
