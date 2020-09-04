class Battle
  class TrainerSprite < CellSprite
    def initialize(gender = 0, viewport = nil)
      super(viewport)
      self.bitmap = Bitmap.new("gfx/trainers/red_back")
      self.set_cell(128, 98)
    end
  end
end
