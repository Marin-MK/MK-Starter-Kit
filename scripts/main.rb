# Starts the main game loop required to keep the game running.

map = MKD::Map.fetch(1)
map.encounter_tables = [
  EncounterTable.new do
    @density = 0.25
    @list = [
      [5, {species: :BULBASAUR, level: 1}],
      [4, {species: :BULBASAUR, level: 2}],
      [3, {species: :BULBASAUR, level: 3}],
      [2, {species: :BULBASAUR, level: 4}],
      [1, {species: :BULBASAUR, level: 5}]
    ]
    @tiles = [
      [0, 6],
      [0, 7], [1, 7],
      [0, 8], [1, 8], [2, 8],
      [0, 9], [1, 9], [2, 9], [3, 9],
      [0, 10], [1, 10], [2, 10], [3, 10], [4, 10], [5, 10],
      [0, 11], [1, 11], [2, 11], [3, 11], [4, 11], [5, 11],
      [0, 12], [1, 12], [2, 12], [3, 12], [4, 12], [5, 12], [6, 12],
      [0, 13], [1, 13], [2, 13], [3, 13], [4, 13], [5, 13], [6, 13], [7, 13],
      [0, 14], [1, 14], [2, 14], [3, 14], [4, 14], [5, 14], [6, 14], [7, 14]
    ]
  end
]
map.save

# Initialize important game variables
$LOG = {
  WARNING: true,
  SYSTEM: true,
  OVERWORLD: false,
  UI: true
}

$temp = TempData.new
$visuals = Visuals.new
$game = Game.new
$game.switches = Game::Switches.new
$game.variables = Game::Variables.new
$game.player = Game::Player.new(3)
$game.load_map(3)
$trainer = Trainer.new
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 12, item: :REPEL))
$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 32);p.exp+=2000;p))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 3, gender: 1, status: :paralyzed, hp: 13))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 4, item: :REPEL))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 5, hp: 6, status: :poisoned))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 6, gender: 1, hp: 0))
$trainer.add_item(:MAXREPEL, 5)

def main_function
  $game.update
  $visuals.update
  if Input.trigger?(Input::CTRL)
    Battle.new($trainer, Pokemon.new(:BULBASAUR, 5))
    #return false
  end
  return true
end

main_function
loop do
  update = System.update
  if defined?(APPLICATION) && APPLICATION == "ruby-sdl2"
    break unless update
  end
  break if !main_function
end
