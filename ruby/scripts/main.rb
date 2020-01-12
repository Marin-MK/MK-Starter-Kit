# Starts the main game loop required to keep the game running.

# Initializes the game
$LOG = {}
$temp = TempData.new
$visuals = Visuals.new
$game = Game.new
$game.switches = Game::Switches.new
$game.variables = Game::Variables.new
$game.player = Game::Player.new(1)
$game.player.setup_visuals
$game.load_map(1)
$visuals.map_renderer.create_tiles if $visuals.map_renderer.empty?
$trainer = Trainer.new

$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 100, gender: 1, item: :REPEL, hp: 37))
$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 32);p.exp+=2000;p))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 3, gender: 1, status: :PARALYSIS, hp: 13))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 4, item: :REPEL))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 5, hp: 6, status: :POISON))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 6, gender: 1, hp: 0))

$trainer.add_item(:MAXREPEL, 5)

$LOG[:OVERWORLD] = true

def main_function
  $game.update
  $visuals.update
  if Input.trigger?(Input::SHIFT)
    $visuals.map_renderer.toggle_grid
  end
  if Input.trigger?(Input::CTRL)
    abort
  end
end

loop do
  Input.update
  main_function
  Graphics.update
end
