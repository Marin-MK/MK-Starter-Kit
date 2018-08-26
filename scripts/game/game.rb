class Game
  attr_accessor :map
  attr_accessor :player

  def initialize
  end

  def update
    @player.update
  end
end

tileset = MKD::Tileset.new(1)
tileset.name = "Outdoor"
tileset.graphic_name = "outdoor"
tileset.passabilities = []
tileset.priorities = []
tileset.tags = []
tileset.save

map = MKD::Map.new(1)
map.name = "This is a test map"
map.width = 5
map.height = 5
map.tiles = [
  [
    3,3,3,3,3,
    3,31,3,3,3,
    3,3,16,17,3,
    3,3,24,25,3,
    3,3,3,3,3
  ],
  [
    0,0,0,0,0,
    0,0,8,9,0,
    0,0,0,0,0,
    0,0,0,0,0,
    0,0,0,0,0
  ]
]
map.tileset_id = 1
map.save

$game = Game.new
$game.map = Game::Map.new(1)
$game.player = Game::Player.new