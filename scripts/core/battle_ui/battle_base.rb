class Battle
  class BattleBase < Sprite
    # Creates a new battle base sprite.
    # @param viewport [NilClass, Viewport] the viewport of the base sprite.
    # @param opponent [Boolean] whether the base is on the opposing side.
    def initialize(viewport = nil, opponent = false)
      validate \
          viewport => [NilClass, Viewport],
          opponent => Boolean
      super(viewport)
      self.bitmap = Bitmap.new("gfx/ui/battle/bases/grass_#{opponent ? "opponent" : "player"}")
    end
  end
end
