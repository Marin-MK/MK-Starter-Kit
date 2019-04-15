# Starts the main game loop required to keep the game running.

# Initializes the game
$temp = TempData.new
$visuals = Visuals.new
$game = Game.new
$game.switches = Game::Switches.new
$game.variables = Game::Variables.new
$game.player = Game::Player.new(2)
$game.player.setup
$game.load_map(2)
$visuals.map_renderer.create_tiles if $visuals.map_renderer.empty?
$trainer = Trainer.new

$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 100);p.shiny=true;p.gender=1;p.item=:REPEL;p.hp=37;p))
$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 32);p.exp+=2000;p))
$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 3);p.gender=1;p.status=:PARALYSIS;p.hp-=1;p))
$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 4);p.item=:REPEL;p))
$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 5);p.hp=6;p.status=:POISON;p))
$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 6);p.gender=1;p.hp=0;p))

$trainer.add_item(:REPEL, 5)

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
