class Visuals
  # @return [Hash<Visuals::Map>] the list of maps stored by ID.
  attr_accessor :maps
  # @return [Viewport] the main viewport for all maps and events.
  attr_accessor :viewport
  # @return [Visuals::Player] the player object.
  attr_accessor :player
  # @return [Visuals::MapRenderer] the global tilemap.
  attr_accessor :map_renderer

  # Creates a new Visuals object.
  def initialize
    @maps = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @map_renderer = MapRenderer.new
  end

  # @return [Visuals::Map] the current map object.
  def map
    return @maps[$game.map.id]
  end

  # Updates the maps and player.
  def update
    @maps.values.each(&:update)
    @player.update
  end
end
