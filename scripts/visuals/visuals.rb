class Visuals
  attr_accessor :maps
  attr_accessor :viewport
  attr_accessor :player

  def initialize
    @maps = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  end

  # Returns the visual data for the current map
  def map
    return @maps[$game.map.id]
  end

  def update
    @maps.values.each(&:update)
    @player.update
  end
end

$visuals = Visuals.new