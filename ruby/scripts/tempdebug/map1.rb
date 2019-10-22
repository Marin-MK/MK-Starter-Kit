# Creates a new map (normally loaded from a file)
map = MKD::Map.new(1)
map.dev_name = map.display_name = "Top Left Map"
map.width = 5
map.height = 5
map.tilesets = [1, 3]
map.tiles = [
  [
    [0, 0], [0, 0], [0, 0], [0, 0], [0, 0],
    [0, 0], [0, 0], [0, 0], [0, 0], [0, 0],
    [0, 0], [0, 0], [0, 0], [0, 0], [0, 0],
    [0, 0], [0, 0], [0, 0], [0, 0], [0, 0],
    [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]
  ],
  [
    nil, nil,     [1, 20],  nil,      nil,
    nil, [1, 27], [1, 28],  [1, 29],  nil,
    nil, [1, 35], [1, 36],  [1, 37],  nil,
    nil, [1, 43], [1, 44],  [1, 45],  nil,
    nil, nil,     nil,      nil,      nil,
  ]
]

def create_event(map, id, x, y, dir)
  event = MKD::Event.new(id)
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
    [0, :message, {text: "Okay, you like your profile the way it is."}],
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
  page.automoveroute[:commands] = [:down, :down, :down, :down, :right, :right, :right, :right, :up, :up, :up, :up, :left, :left, :left, :left]

  event.pages = [page]
  map.events[id] = event
end

create_event(map, 1, 0, 0, 2)

map.save
