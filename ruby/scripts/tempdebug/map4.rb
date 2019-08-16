map = MKD::Map.new(4)
map.name = "Bottom Right Map"
map.width = 5
map.height = 5
map.tilesets = [1]
map.tiles = [
  [[0, 185]] * map.width * map.height
]

map.save





map = MKD::Map.new(5)
map.name = "Faraday Island"
map.width = 29
map.height = 31
map.tilesets = [1]
map.tiles = [
  [[0, 185]] * map.width * map.height
]

map.save
