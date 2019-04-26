# Creates a new tileset (normally loaded from a file)
tileset = MKD::Tileset.new(4)
tileset.name = "Water"
tileset.graphic_name = "water"

# 0 = impassable
# 1 = passable down
# 2 = passable left
# 4 = passable right
# 8 = passable up
# 11 = passable down, left, up
# etc.
# 15 = passable all

tileset.passabilities = [
  5,  3,  5,  3,  5,  3,  5,  3,
  12, 10, 12, 10, 12, 10, 12, 10,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 0,  0,  0,  0,  0,
  15, 15, 15, 0,  0,  0,  0,  0,
  15, 15, 15, 0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  15, 0,  0,  0,  0,  0,  0,  0,
]
tileset.priorities = [
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, 1,   1,   1,   1,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, 1,   1,   1,   1,   1,   1,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
]
tileset.tags = []
tileset.save
