class Battle
  class BattleBase < Sprite
    def initialize(viewport = nil, opponent = false)
      super(viewport)
      self.bitmap = Bitmap.new("gfx/ui/battle/bases/grass_#{opponent ? "opponent" : "player"}")
    end
  end
end
