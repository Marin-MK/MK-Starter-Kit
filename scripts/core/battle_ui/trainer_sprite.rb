class Battle
  class TrainerSprite < CellSprite
    # Creates a trainer sprite given a gender and viewport.
    # @param gender [Integer] the gender of the trainer.
    # @param viewport [Viewport] the viewport of the sprite.
    def initialize(gender = 0, viewport = nil)
      validate \
          gender => Integer,
          viewport => [NilClass, Viewport]
      super(viewport)
      self.bitmap = Bitmap.new("gfx/trainers/red_back")
      self.set_cell(128, 98)
    end
  end
end
