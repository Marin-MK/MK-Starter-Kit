# Creates a new tileset (normally loaded from a file)
tileset = MKD::Tileset.new(2)
tileset.name = "Paths"
tileset.graphic_name = "paths"

# 0 = impassable
# 1 = passable down
# 2 = passable left
# 4 = passable right
# 8 = passable up
# 11 = passable down, left, up
# etc.
# 15 = passable all

tileset.passabilities = [15] * 8 * 23
tileset.priorities = []
tileset.tags = []
tileset.save
