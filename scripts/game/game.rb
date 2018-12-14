class Game
  # @return [Game::Player] the player object.
  attr_accessor :player
  # @return [Game::Switches] the global game switches.
  attr_accessor :switches
  # @return [Game::Variables] the global game variables.
  attr_accessor :variables
  # @return [Hash<Fixnum, Game::Map>] the global collection of game maps.
  attr_accessor :maps

  # Creates a new Game object.
  def initialize
    @maps = {}
  end

  # @return [Game::Map] the map the player is currently on.
  def map
    return @maps[$game.player.map_id]
  end

  # Updates the maps and player.
  def update
    @maps.values.each(&:update)
    @player.update
  end
end

# Initializes the game
$game = Game.new
$game.switches = Game::Switches.new
$game.variables = Game::Variables.new
$game.maps[1] = Game::Map.new(1)
$game.player = Game::Player.new(1)
$visuals.map_renderer.create_tiles if $visuals.map_renderer.empty?
