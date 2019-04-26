map = MKD::Map.new(2)
map.name = "MT. MOON"
map.width = 5
map.height = 5
map.tilesets = [1]
map.tiles = [
  [[0, 137]] * map.width * map.height
]

map.save
