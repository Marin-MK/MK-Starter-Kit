class TypeIcon < Sprite
  def initialize(type, viewport = nil)
    validate type => [Type, Symbol, Integer]
    super(viewport)
    self.set_bitmap("gfx/misc/types")
    self.src_rect.height = self.bitmap.height / Type.count
    set_type(type)
  end

  def set_type(type)
    validate type => [Type, Symbol, Integer]
    type = Type.get(type)
    # -1 since types start with ID 1
    self.src_rect.y = (type.id - 1) * self.src_rect.height
  end
end
