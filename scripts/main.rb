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

p = Pokemon.new(:BULBASAUR, 100)
msgbox "Name: #{p.name}\nForm: #{p.form}\nEXP: #{p.exp}\nLevel: #{p.level}\nType1: #{p.type1.intname}\nType2: #{p.type2.intname}"
p.item = :REPEL
msgbox "Name: #{p.name}\nForm: #{p.form}\nEXP: #{p.exp}\nLevel: #{p.level}\nType1: #{p.type1.intname}\nType2: #{p.type2.intname}"
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
