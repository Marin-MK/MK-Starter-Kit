# Starts the main game loop required to keep the game running.

# Initializes the game
$visuals = Visuals.new
$game = Game.new
$game.switches = Game::Switches.new
$game.variables = Game::Variables.new
$game.player = Game::Player.new(2)
$game.player.setup
$game.load_map(2)
$visuals.map_renderer.create_tiles if $visuals.map_renderer.empty?
$trainer = Trainer.new

#shinies = []
#8000.times do
#  p = Pokemon.new(:BULBASAUR, 100)
#  shinies << p.shiny
#end
#shiny = shinies.select { |e| e }.size
#notshiny = shinies.select { |e| !e }.size
#msgbox "Shinies: #{shiny}\nNot shiny: #{notshiny}"

#genders = []
#8000.times do
#  p = Pokemon.new(:BULBASAUR, 100)
#  genders << p.gender
#end
#males = genders.select { |e| e == 0 }.size
#females = genders.select { |e| e == 1 }.size
#genderless = genders.select { |e| e == 2 }.size
#msgbox "Males: #{males}\nFemales: #{females}\nGenderless: #{genderless}"

p = Pokemon.new(:BULBASAUR, 100)
msgbox p.gender
msgbox p.nature.name
msgbox p.ability.name
msgbox p.shiny
$trainer.add_pokemon(p)

loop do
  Input.update
  $game.update
  $visuals.update
  if Input.trigger?(Input::SHIFT)
    $visuals.map_renderer.toggle_grid
  end
  if Input.trigger?(Input::CTRL)
    abort
  end
  Graphics.update
end
