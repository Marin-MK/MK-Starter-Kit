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
tileset.save


# Creates a new map (normally loaded from a file)
map = MKD::Map.new(1)
map.name = "Some Town"
map.width = 10
map.height = 10
map.tilesets = [1, 1]
map.tiles = [
  # Fills exactly the whole map with [0, 1]
  [[0, 1]] * map.width * map.height
]


def create_event(map, id, x, y, dir)
  event = MKD::Event.new
  event.x = x
  event.y = y
  event.name = "New event"
  event.settings.passable = false
  event.settings.speed = 1.0

  page = MKD::Event::Page.new
  page.graphic.type = 0
  page.graphic.param = "gfx/characters/boy"
  page.graphic.direction = dir
  page.commands = [
    #[0, :debug_print, {text: "Hello nigger"}]
    #[0, :move, {commands: [:right, :down]}]
    
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

  page.conditions = []
  
  page.triggers = [
    [:action],
    #[:line_of_sight, {tiles: 3}],
    #[:on_tile, {tiles: [[1, 1], [1, 2], [2, 1], [2, 2]]}],
    #[:player_touch],
    #[:event_touch]
    #[:parallel_process],
    #[:autorun],
  ]

  page.automoveroute[:frequency] = 0
  page.automoveroute[:commands] = [:down, :down, :right, :right, :up, :up, :left, :left]

  event.pages = [page]
  map.events[id] = event
end

create_event(map, 1, 0, 1, 2)
create_event(map, 2, 0, 5, 2)
create_event(map, 3, 4, 1, 2)
create_event(map, 4, 4, 5, 2)
create_event(map, 5, 7, 1, 2)
create_event(map, 6, 7, 5, 2)

map.events[2].settings.speed = 1.5
map.events[3].settings.speed = 2.0
map.events[4].settings.speed = 2.5
map.events[5].settings.speed = 4.0
map.events[6].settings.speed = 6.5

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