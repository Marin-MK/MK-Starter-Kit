# Creates a new tileset (normally loaded from a file)
tileset = MKD::Tileset.new(5)
tileset.name = "Mountains"
tileset.graphic_name = "mountains"

# 0 = impassable
# 1 = passable down
# 2 = passable left
# 4 = passable right
# 8 = passable up
# 11 = passable down, left, up
# etc.
# 15 = passable all

tileset.passabilities = [
  15, 15, 15, 8,  8,  8,  4,  2,
  15, 15, 15, 15, 0,  0,  4,  2,
  0,  0,  0,  15, 0,  0,  4,  2,
  15, 0,  0,  15, 15, 15, 0,  0,
  0,  15, 0,  0,  15, 0,  0,  0,
  0,  15, 0,  0,  15, 0,  15, 0,
  0,  0,  0,  0,  0,  0,  15, 15,
  0,  15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 0,  0,  15, 15, 15, 15, 15,
  15, 0,  0,  15, 15, 15, 15, 15,
]
tileset.priorities = [
  nil, 1,   1,   nil, nil, nil, nil, nil,
  nil, 2,   2,   nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, 2,   2,   nil, nil, nil, nil, nil,
  nil, 1,   1,   nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil,
]
tileset.tags = []
tileset.save
