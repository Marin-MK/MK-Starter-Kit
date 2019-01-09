# Creates a new map (normally loaded from a file)
map = MKD::Map.new(1)
map.name = "Some Town"
map.width = 15
map.height = 25
map.tilesets = [1, 2, 3, 4, 5, 6]
map.tiles = [
  # Fills exactly the whole map with [0, 1]
  [[0, 0]] * map.width * map.height
]

# Top-left grass
map.tiles[0][0] = [0, 9]

# Path
map.tiles[0][map.width * 2 + 4] = [1, 0]
map.tiles[0][map.width * 2 + 5] = [1, 1]
map.tiles[0][map.width * 2 + 6] = [1, 2]
map.tiles[0][map.width * 3 + 3] = [1, 0]
map.tiles[0][map.width * 3 + 4] = [1, 33]
map.tiles[0][map.width * 3 + 5] = [1, 24]
map.tiles[0][map.width * 3 + 6] = [1, 18]
map.tiles[0][map.width * 4 + 3] = [1, 8]
map.tiles[0][map.width * 4 + 4] = [1, 24]
map.tiles[0][map.width * 4 + 5] = [1, 18]
map.tiles[0][map.width * 5 + 3] = [1, 16]
map.tiles[0][map.width * 5 + 4] = [1, 18]

# Tree
map.tiles[1] = []
map.tiles[1][map.width * 5 + 11] = [2, 68]
map.tiles[1][map.width * 6 + 10] = [2, 75]
map.tiles[1][map.width * 6 + 11] = [2, 76]
map.tiles[1][map.width * 6 + 12] = [2, 77]
map.tiles[1][map.width * 7 + 10] = [2, 83]
map.tiles[1][map.width * 7 + 11] = [2, 84]
map.tiles[1][map.width * 7 + 12] = [2, 85]
map.tiles[1][map.width * 8 + 10] = [2, 91]
map.tiles[1][map.width * 8 + 11] = [2, 92]
map.tiles[1][map.width * 8 + 12] = [2, 93]

# Boat
map.tiles[1][map.width * 6 + 3] = [3, 122]
map.tiles[1][map.width * 6 + 4] = [3, 123]
map.tiles[1][map.width * 6 + 5] = [3, 124]
map.tiles[1][map.width * 6 + 6] = [3, 125]
map.tiles[1][map.width * 6 + 7] = [3, 126]
map.tiles[1][map.width * 6 + 8] = [3, 127]
map.tiles[1][map.width * 7 + 1] = [3, 128]
map.tiles[1][map.width * 7 + 2] = [3, 129]
map.tiles[1][map.width * 7 + 3] = [3, 130]
map.tiles[1][map.width * 7 + 4] = [3, 131]
map.tiles[1][map.width * 7 + 5] = [3, 132]
map.tiles[1][map.width * 7 + 6] = [3, 133]
map.tiles[1][map.width * 7 + 7] = [3, 134]
map.tiles[1][map.width * 7 + 8] = [3, 135]
map.tiles[1][map.width * 8 + 1] = [3, 136]
map.tiles[1][map.width * 8 + 2] = [3, 137]
map.tiles[1][map.width * 8 + 3] = [3, 138]
map.tiles[1][map.width * 8 + 4] = [3, 139]
map.tiles[1][map.width * 8 + 5] = [3, 140]
map.tiles[1][map.width * 8 + 6] = [3, 141]
map.tiles[1][map.width * 8 + 7] = [3, 142]
map.tiles[1][map.width * 8 + 8] = [3, 143]
map.tiles[1][map.width * 9 + 1] = [3, 144]
map.tiles[1][map.width * 9 + 2] = [3, 145]
map.tiles[1][map.width * 9 + 3] = [3, 146]
map.tiles[1][map.width * 9 + 4] = [3, 147]
map.tiles[1][map.width * 9 + 5] = [3, 148]
map.tiles[1][map.width * 9 + 6] = [3, 149]
map.tiles[1][map.width * 9 + 7] = [3, 150]
map.tiles[1][map.width * 9 + 8] = [3, 151]

# Rock
map.tiles[1][map.width * 1 + 8] = [4, 57]
map.tiles[1][map.width * 1 + 9] = [4, 58]
map.tiles[1][map.width * 2 + 8] = [4, 65]
map.tiles[1][map.width * 2 + 9] = [4, 66]
map.tiles[1][map.width * 3 + 8] = [4, 73]
map.tiles[1][map.width * 3 + 9] = [4, 74]
map.tiles[1][map.width * 4 + 7] = [4, 80]
map.tiles[1][map.width * 4 + 8] = [4, 81]
map.tiles[1][map.width * 4 + 9] = [4, 82]
map.tiles[1][map.width * 4 + 10] = [4, 83]

# Rails
map.tiles[1][map.width * 1 + 12] = [5, 88]
map.tiles[1][map.width * 1 + 13] = [5, 89]
map.tiles[1][map.width * 1 + 14] = [5, 90]
map.tiles[1][map.width * 2 + 12] = [5, 96]
map.tiles[1][map.width * 2 + 14] = [5, 98]
map.tiles[1][map.width * 3 + 12] = [5, 104]
map.tiles[1][map.width * 3 + 13] = [5, 105]
map.tiles[1][map.width * 3 + 14] = [5, 106]

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

  page.automoveroute[:frequency] = 0
  page.automoveroute[:commands] = [:turn_to_player]

  event.pages = [page]
  map.events[id] = event
end

create_event(map, 1, 7, 1, 2)

# Overwrites tileset passability data for non-nil entries.
map.passabilities = [
  # Makes x=2,y=0 impassable
  #15/nil, 15/nil, 0
]
map.save
