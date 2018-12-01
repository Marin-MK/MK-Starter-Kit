class Game
  attr_accessor :map
  attr_accessor :player
  attr_accessor :switches
  attr_accessor :variables

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
map.width = 7
map.height = 7
map.tiles = [
  [ # Layer 1
    3,3,3,3,3,3,3,
    3,3,3,3,3,3,3,
    3,3,3,3,3,3,3,
    3,3,3,3,3,3,3,
    3,3,3,3,3,3,3,
    3,3,3,3,3,3,3,
    3,3,3,3,3,3,3,

    #3,3,16,17,3,
    #3,3,24,25,3,
  ],
  [ # Layer 2
    nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,
  ]
]


def create_event(map, id, x, y, dir)
  event = MKD::Event.new
  event.x = x
  event.y = y
  event.name = "New event"
  event.settings.passable = false

  page = MKD::Event::Page.new
  page.graphic.type = 0
  page.graphic.param = "gfx/characters/boy"
  page.graphic.direction = dir
  page.commands = [
    [0, :console_print, {text: "Working."}]

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
    #[:action],
    #[:line_of_sight, {tiles: 6}],
    #[:on_tile, {tiles: [[1, 1], [1, 2], [2, 1], [2, 2]]}],
    [:parallel_process],
    #[:autorun]
  ]

  event.pages = [page]
  map.events[id] = event
end

create_event(map, 1, 0, 1, 6)
create_event(map, 2, 0, 2, 6)
map.events[2].pages[0].triggers = [[:action]]
map.events[2].pages[0].conditions = []
map.events[2].pages[0].commands = [
  [0, :if, {condition: [:switch, {switchid: 1, value: true}]}],
  [1, :setswitch, {switchid: 1, value: false}],
  [1, :debug_print, {text: "Switch 1 has been turned off."}],
  [0, :else],
  [1, :setswitch, {switchid: 1, value: true}],
  [1, :debug_print, {text: "Switch 1 has been turned on."}],
]

# Overwrites tileset passability data for non-nil entries.
map.passabilities = []
map.tileset_id = 1
map.save

# Initializes the game
$game = Game.new
$game.switches = Game::Switches.new
$game.variables = Game::Variables.new
$game.map = Game::Map.new(1)
$game.player = Game::Player.new