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
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 14, item: :REPEL))
$trainer.add_pokemon((p=Pokemon.new(:BULBASAUR, 32);p.exp+=2000;p))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 3, gender: 1, status: :paralyzed, hp: 13))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 4, item: :REPEL))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 5, hp: 6, status: :poisoned))
$trainer.add_pokemon(Pokemon.new(:BULBASAUR, 6, gender: 1, hp: 0))
$trainer.add_item(:MAXREPEL, 5)
$trainer.add_item(:REPEL, 2)
$trainer.give_pokedex

def main_function
  $game.update
  $visuals.update
  if Input.trigger?(Input::CTRL)
    wild_battle(Pokemon.new(:BULBASAUR, 14, ivs: $trainer.party[0].ivs, nature: $trainer.party[0].nature, moves: [UsableMove.new(:TACKLE), UsableMove.new(:GROWL)]))
  end
  return true
end

$fps_sprite = Sprite.new
$fps_sprite.z = 999999999
$fps_sprite.bitmap = Bitmap.new(System.width, System.height)

class << System
  alias misc_update update
  def update
    if Input.trigger?(Input::Q)
      System.render_speed /= 2
    elsif Input.trigger?(Input::E)
      System.render_speed *= 2
    end
    if @before_ruby
      @after_ruby = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @ruby_total ||= 0
      @ruby_count ||= 0
      @ruby_total += @after_ruby - @before_ruby
      @ruby_count += 1
    end
    if @render_count == System.frame_rate
      render_avg = (@render_count / @render_total).round
      render_str = "Render FPS: #{render_avg}"
      ruby_avg = (@ruby_count / @ruby_total).round
      ruby_str = "Ruby FPS: #{ruby_avg}"
      $fps_sprite.bitmap.clear
      $fps_sprite.bitmap.draw_text(
        x: System.width - 8, y: 8, align: :right, color: Color.new(96, 96, 96), text: ruby_str
      )
      $fps_sprite.bitmap.draw_text(
        x: System.width - 8, y: 40, align: :right, color: Color.new(96, 96, 96), text: render_str
      )
      @render_total = @render_count = 0
      @ruby_total = @ruby_count = 0
    end
    before_render = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    misc_update
    after_render = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @render_total ||= 0
    @render_count ||= 0
    @render_total += after_render - before_render
    @render_count += 1
    @before_ruby = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end

main_function
loop do
  System.update
  break if !main_function
end
