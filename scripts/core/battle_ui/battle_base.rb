class Battle
  class BattleBase < Sprite
    # Creates a new battle base sprite.
    # @param viewport [Viewport] the viewport of the base sprite.
    # @param opponent [Boolean] whether the base is on the opposing side.
    def initialize(viewport = nil, opponent = false)
      super(viewport)
      self.bitmap = Bitmap.new("gfx/ui/battle/bases/grass_#{opponent ? "opponent" : "player"}")
    end
  end
end
