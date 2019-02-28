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
$trainer.add_pokemon(p)

#msgbox $trainer.get_quantity(:REPEL)
$trainer.add_item(:REPEL, 4)
#msgbox $trainer.get_quantity(:REPEL)
$trainer.remove_item(:REPEL, 4)
#msgbox $trainer.get_quantity(:REPEL)


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
