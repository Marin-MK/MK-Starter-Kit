class StatusConditionIcon < Sprite
  def initialize(arg, viewport = nil)
    validate arg => [Pokemon, Symbol]
    if arg.is_a?(Pokemon)
      if arg.fainted?
        arg = :FAINTED
      else
        arg = arg.status
      end
    end
    status = arg
    super(viewport)
    return if status.nil?
    self.set_bitmap("gfx/misc/status_conditions")
    self.src_rect.height = self.bitmap.height / 7
    indexes = {
      :burned => 0,
      :frozen => 1,
      :paralyzed => 2,
      :poisoned => 3,
      :asleep => 4,
      :fainted => 5,
      :pokerus => 6
    }
    raise "Invalid status condition #{status.inspect}" if !indexes[status]
    index = indexes[status]
    self.src_rect.y = index * self.src_rect.height
  end
end
