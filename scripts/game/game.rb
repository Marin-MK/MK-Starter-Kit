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
tileset.passabilities = [] # lazy
tileset.priorities = [] # lazy
tileset.tags = [] # lazy
tileset.save

# Createsa new map (normally loaded from a file)
map = MKD::Map.new(1)
map.name = "Some Town"
map.width = 5
map.height = 5
map.tiles = [
  [ # Layer 1
    3,3,3,3,3,
    3,31,3,3,3,
    3,3,16,17,3,
    3,3,24,25,3,
    3,3,3,3,3
  ],
  [ # Layer 2
    0,0,0,0,0,
    0,0,8,9,0,
    0,0,0,0,0,
    0,0,0,0,0,
    0,0,0,0,0
  ]
]
map.tileset_id = 1
map.save

# Initializes the game
$game = Game.new
$game.map = Game::Map.new(1)
$game.player = Game::Player.new