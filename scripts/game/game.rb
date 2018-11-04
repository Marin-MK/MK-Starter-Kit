class Game
  attr_accessor :map
  attr_accessor :player

  def initialize
  end

  def update
    @map.update
    @player.update
  end
end

# Creates a new tileset (normally loaded from a file)
tileset = MKD::Tileset.new(1)
tileset.name = "Outdoor"
tileset.graphic_name = "outdoor"

# 0 = impassable
# 1 = passable down
# 2 = passable left
# 4 = passable right
# 8 = passable up

# 11 = passable down, left, up
# etc.

# 15 = passable all

tileset.passabilities = [
  15,0, 15,15,15,15,15,15,
  15,15,0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
]
# Which z layer the tiles appear on. 0 and nil = 10, 1 = 12, 2 = 14, etc.
tileset.priorities = [
  nil,nil,nil,nil,nil,nil,nil,nil,
   1 , 1 ,nil,nil,nil,nil,nil,nil,
  nil,nil,nil,nil,nil,nil,nil,nil,
  nil,nil,nil,nil,nil,nil,nil,nil,
]
tileset.tags = [] # lazy
tileset.save

# Creates a new map (normally loaded from a file)
map = MKD::Map.new(1)
map.name = "Some Town"
map.width = 5
map.height = 5
map.tiles = [
  [ # Layer 1
    3,3, 3, 3, 3,
    3,31,3, 3, 3,
    3,3, 16,17,3,
    3,3, 24,25,3,
    3,3, 3, 3, 3
  ],
  [ # Layer 2
    nil,nil,nil,nil,nil,
    nil,nil, 8 , 9 ,nil,
    nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,
  ]
]

event = MKD::Event.new
event.x = 1
event.y = 3
event.name = "New event"
event.settings.passable = false
state = MKD::Event::State.new
state.graphic.type = 0
state.graphic.param = "gfx/characters/boy"
state.graphic.direction = 6
event.states = [state]
map.events = {1 => event}

# Overwrites tileset passability data for non-nil entries.
map.passabilities = []
map.tileset_id = 1
map.save

# Initializes the game
$game = Game.new
$game.map = Game::Map.new(1)
$game.player = Game::Player.new