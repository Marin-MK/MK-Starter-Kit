class SelectableSprite < Sprite
  def initialize(viewport = nil)
    super(viewport)
    @state = 0
  end

  def set_bitmap(path, possible_states = 2)
    self.bitmap = Bitmap.new(path)
    self.src_rect.width = self.bitmap.width / possible_states
    self.select(@state)
  end

  def select(state = 1)
    @state = state
    self.src_rect.x = self.src_rect.width * @state
  end

  def deselect(state = 0)
    self.select(state)
  end
end
