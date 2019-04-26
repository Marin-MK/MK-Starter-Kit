# Creates a new tileset (normally loaded from a file)
tileset = MKD::Tileset.new(1)
tileset.name = "Common"
tileset.graphic_name = "common"

# 0 = impassable
# 1 = passable down
# 2 = passable left
# 4 = passable right
# 8 = passable up
# 11 = passable down, left, up
# etc.
# 15 = passable all

tileset.passabilities = [
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 0,  0,  0,
  0,  0,  0,  0,  15, 15, 0,  0,
  0,  0,  0,  0,  0,  0,  15, 15,
  0,  0,  0,  0,  0,  0,  15, 0,
  0,  0,  0,  0,  15, 15, 15, 0,
  0,  15, 15, 0,  15, 0,  0,  0,
  0,  15, 15, 0,  15, 15, 0,  0,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 0,  0,  0,  0,  0,
  0,  15, 0,  0,  15, 0,  0,  0,
  0,  15, 0,  0,  15, 0,  15, 15,
  0,  0,  0,  0,  0,  0,  0,  0,
  4,  2,  8,  8,  8,  15, 15, 15,
  4,  2,  0,  0,  15, 15, 15, 15,
  4,  2,  0,  0,  15, 15, 15, 15,
  5,  7,  3,  15, 15, 5,  7,  3,
  13, 15, 11, 15, 15, 13, 15, 11,
  12, 14, 10, 15, 15, 12, 14, 10,
  15, 15, 15, 15, 15, 15, 15, 15,
  11, 13, 15, 15, 15, 15, 11, 13,
  11, 13, 15, 15, 15, 15, 11, 13,
  11, 13, 15, 15, 15, 15, 11, 13,
  15, 15, 15, 15, 15, 15, 15, 15,
]
tileset.priorities = [
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, 1,   nil, nil, nil, nil,
  nil, nil, nil, nil, 1,   1,   nil, nil,
  nil, nil, nil, nil, nil, nil, nil, 1,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, 1,   1,   nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
]
tileset.tags = []
tileset.save
