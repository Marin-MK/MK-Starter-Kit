# Creates a new map (normally loaded from a file)
map = MKD::Map.new(1)
map.name = "Some Town"
map.width = 5
map.height = 5
map.tilesets = [1]
map.tiles = [
  # Fills exactly the whole map with [0, 1]
  [[0, 0]] * map.width * map.height
]

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
    [0, :message, {text: "Hello {PLAYER}! It's been a while since I last saw you.\nHow's everything going?"}],
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
  page.automoveroute[:commands] = [:left, :left, :down, :down, :right, :right, :up, :up]

  event.pages = [page]
  map.events[id] = event
end

create_event(map, 1, 1, 1, 2)
map.events[1].pages[0].automoveroute[:commands] = []
create_event(map, 2, 3, 2, 4)

# Overwrites tileset passability data for non-nil entries.
map.passabilities = [
  # Makes x=2,y=0 impassable
  #15/nil, 15/nil, 0
]
map.save
