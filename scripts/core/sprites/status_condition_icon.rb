class StatusConditionIcon < Sprite
  attr_reader :status

  def initialize(arg, viewport = nil)
    super(viewport)
    self.status = arg
  end

  def status=(arg)
    validate arg => [Battle::Battler, Pokemon, Symbol]
    if arg.is_a?(Battle::Battler, Pokemon)
      if arg.fainted?
        arg = :fainted
      else
        arg = arg.status
      end
    end
    @status = arg
    return if @status.nil?
    self.bitmap = Bitmap.new("gfx/misc/status_conditions")
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
    raise "Invalid status condition #{status.inspect}" if !indexes[@status]
    index = indexes[@status]
    self.src_rect.y = index * self.src_rect.height
  end
end
