class Visuals
  attr_accessor :maps
  attr_accessor :viewport
  attr_accessor :player

  def initialize
    @maps = []
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  end

  def update
    @player.update
  end
end

$visuals = Visuals.new