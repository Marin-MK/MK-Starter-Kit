map = MKD::Map.new(2)
map.name = "Some Town"
map.width = 7
map.height = 7
map.tilesets = [1, 1]
map.tiles = [[]]
for i in 0...map.width * map.height
  map.tiles[0] << [0, i % 2 == 0 ? 9 : 0]
end

e = MKD::Event.new(1)
e.x = 1
e.y = 0
e.settings.passable = false
p = MKD::Event::Page.new
p.graphic = {
  type: :file,
  direction: 4,
  param: "gfx/characters/boy"
}
p.commands = [
  [0, :transfer, {mapid: 1, x: 34, y: 2}]
]
p.triggers = [[:action]]
e.pages << p

map.events[1] = e

map.save
