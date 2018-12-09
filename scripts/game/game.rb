class Game
  # @return [Game::Map] the map the player is currently on.
  attr_accessor :map
  # @return [Game::Player] the player object.
  attr_accessor :player
  # @return [Game::Switches] the global game switches.
  attr_accessor :switches
  # @return [Game::Variables] the global game variables.
  attr_accessor :variables

  # Creates a new Game object.
  def initialize
  end

  # Updates the maps and player.
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
  0,  15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 15, 0,  0,  15, 15,
  15, 15, 15, 15, 15, 0,  15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 0,  0,  15, 15, 0,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 15, 0,  0,  15, 15,
  15, 15, 15, 15, 15, 0,  15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 0,  0,  15, 15, 0,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 15, 15, 0,  15, 15,
  15, 15, 15, 15, 15, 0,  15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 0,  0,  15, 15, 0,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 15, 0,  0,  15, 15,
  15, 15, 15, 15, 15, 0,  15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 0,  0,  15, 15, 0,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 15, 0,  0,  15, 15,
  15, 15, 15, 15, 15, 0,  15, 15,
  15, 15, 15, 15, 15, 15, 15, 0,
  15, 15, 15, 15, 15, 15, 15, 0,
  0,  0,  0,  15, 15, 0,  0,  0,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 0,  0,  15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 0,  0,  0,
  15, 15, 15, 15, 15, 0,  0,  0,
  15, 15, 15, 0,  0,  0,  0,  0,
  15, 15, 15, 15, 15, 0,  0,  0,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  0,  0,  0,  0,  15, 15, 0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  15, 15, 0,
  0,  0,  0,  0,  0,  15, 15, 0,
  # past first trees
  0,  15, 0,  0,  0,  0,  15, 0,
  0,  0,  0,  0,  0,  0,  0,  15,
  0,  0,  0,  0,  15, 0,  15,  0,
  0,  0,  0,  0,  0,  0,  15,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  # past second trees
  0,  15, 0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  15, 0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  # past third trees
  0,  0,  0,  15, 15, 15, 0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  15, 15, 15, 15, 15, 0,  0,  0,
  15, 15, 15, 15, 15, 0,  0,  0,
  15, 15, 15, 15, 15, 0,  0,  0,
  15, 15, 15, 15, 15, 0,  0,  0,
  15, 15, 15, 15, 15, 0,  0,  0,
  # past brown road thingy
  15, 15, 15, 0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  15, 15, 15,
  0,  0,  0,  0,  0,  15, 15, 15,
  0,  0,  0,  0,  0,  15, 15, 15,
  0,  0,  0,  0,  0,  15, 15, 15,
  0,  0,  0,  0,  0,  15, 0,  15,
  0,  0,  0,  15, 0,  15, 15, 15,
  # end of first empty rain pond
  0,  0,  0,  0,  0,  15, 15, 15,
  0,  0,  0,  0,  0,  15, 0,  15,
  0,  0,  0,  0,  0,  15, 15, 15,
  0,  0,  0,  0,  0,  15, 15, 15,
  0,  15, 15, 0,  0,  15, 0,  15,
  0,  15, 15, 0,  0,  15, 15, 15,
  # start mountain
  0,  15, 0,  0,  0,  0,  15, 15,
  0,  15, 0,  0,  15, 0,  15, 0,
  0,  0,  0,  0,  0,  0,  15, 15,
  0,  0,  0,  0,  0,  0,  0,  0,
  15, 15, 0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  # end ledges
  15, 15, 15, 0,  15, 15, 0,  0,
  15, 15, 15, 0,  15, 15, 0,  0,
  15, 15, 15, 0,  0,  0,  0,  0,
  15, 15, 15, 15, 0,  0,  15, 0,
  # start grey mountain
  0,  15, 0,  0,  15, 0,  15, 15,
  0,  15, 0,  0,  15, 0,  15, 0,
  0,  0,  0,  0,  0,  0,  15, 15,
  0,  0,  0,  0,  0,  0,  0,  0,
  15, 15, 0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  # end grey mountain
  15, 15, 15, 0,  15, 15, 0,  0,
  15, 15, 15, 0,  15, 15, 0,  0,
  15, 15, 15, 0,  0,  0,  0,  0,
  15, 15, 15, 15, 0,  0,  15, 0,
  0,  0,  15, 0,  0,  0,  0,  0,
]

# Which z layer the tiles appear on. 0/nil = 10, 1 = 12, 2 = 14, etc.
tileset.priorities = []
tileset.tags = []
tileset.priorities[420] = 1
tileset.priorities[421] = 1
tileset.priorities[7] = 1
tileset.save


# Creates a new map (normally loaded from a file)
map = MKD::Map.new(1)
map.name = "Some Town"
map.width = 25
map.height = 25
map.tilesets = [1, 1]
map.tiles = [
  # Fills exactly the whole map with [0, 1]
  [[0, 1]] * map.width * map.height
]

map.tiles[0][0] = [0, 6]
map.tiles[0][map.height * 4 + 4] = [0, 426]
map.tiles[0][map.height * 4 + 5] = [0, 427]
map.tiles[0][map.height * 5 + 4] = [0, 432]
map.tiles[0][map.height * 5 + 5] = [0, 433]
map.tiles[1] = []
map.tiles[1][map.height * 3 + 4] = [0, 420]
map.tiles[1][map.height * 3 + 5] = [0, 421]


def create_event(map, id, x, y, dir)
  event = MKD::Event.new
  event.x = x
  event.y = y
  event.name = "New event"
  event.settings.passable = false

  page = MKD::Event::Page.new
  page.graphic = {
    type: :file,
    direction: dir,
    param: "gfx/characters/boy"
  }

  page.commands = [
    [0, :script, {code: "turn_to_player"}],
    #[0, :script, {code: "msgbox caller.join(\"\n\")"}]

    #[0, :if, {condition: [:triggered_by, {mode: :line_of_sight}]}],
    #[1, :debug_print, {text: "Moving!"}],
    #[1, :move, {commands: [:right, :right, :right], ignore_impassable: true}],
    #[0, :else],
    #[1, :if, {condition: [:triggered_by, {mode: :action}]}],
    #[2, :debug_print, {text: "Action!"}],
    #[1, :else],
    #[2, :debug_print, {text: "Event Touch"}]

    #[0, :script, {code: "2000.times { |i| puts i }"}],
    #[0, :setswitch, {switchid: 1, value: true}]

    #[0, :move, {commands: [:right,:right,:up,:up], wait_for_completion: true}],
    #[0, :move, {commands: [:right, :right, :down, :left, :left, :left, :left, :down], ignore_impassable: true}]
    #[0, :debug_print, {text: "Done moving"}]

    #[0, :debug_print, {text: "Wait 2 seconds"}],
    #[0, :wait, {frames: 120}],
    #[0, :debug_print, {text: "Done waiting"}]

    #[0, :if, {condition: [:switch, {switchid: 1, value: true}]}],
    #[1, :setswitch, {switchid: 1, value: false}],
    #[1, :debug_print, {text: "Switch 1 has been turned off."}],
    #[0, :else],
    #[1, :setswitch, {switchid: 1, value: true}],
    #[1, :debug_print, {text: "Switch 1 has been turned on."}],

    #[0, :if, {condition: [:script, {code: "true"}]}],
    #[1, :debug_print, {text: "Level 1"}],
    #[1, :if, {condition: [:script, {code: "true"}]}],
    #[2, :debug_print, {text: "Level 2"}],
    #[2, :if, {condition: [:script, {code: "true"}]}],
    #[3, :debug_print, {text: "Level 3"}],
    #[2, :else],
    #[3, :debug_print, {text: "Not level 3"}],
    #[1, :else],
    #[2, :debug_print, {text: "Not level 2"}],
    #[0, :else],
    #[1, :debug_print, {text: "Not level 1"}]
  ]

  page.conditions = [
    [:switch, {switchid: 1, value: false}]
  ]

  page.triggers = [
    [:action],
    #[:line_of_sight, {tiles: 3}],
    #[:on_tile, {tiles: [[1, 1], [1, 2], [2, 1], [2, 2]]}],
    #[:player_touch],
    #[:event_touch]
    #[:parallel_process],
    #[:autorun],
  ]

  #page.automoveroute[:frequency] = 0
  #page.automoveroute[:commands] = [:down, :down, :right, :right, :up, :up, :left, :left]

  event.pages = [page]
  map.events[id] = event
end

create_event(map, 1, 3, 4, 2)

# Overwrites tileset passability data for non-nil entries.
map.passabilities = [
  # Makes x=2,y=0 impassable
  #15/nil, 15/nil, 0
]
map.save

# Initializes the game
$game = Game.new
$game.switches = Game::Switches.new
$game.variables = Game::Variables.new
$game.map = Game::Map.new(1)
$game.player = Game::Player.new
