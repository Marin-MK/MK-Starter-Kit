class ArrowSprite < Sprite
  def initialize(direction, viewport = nil)
    validate direction => Symbol,
        viewport => [Viewport, NilClass]
    @direction = direction
    super(viewport)
    self.set_bitmap("gfx/misc/arrow_#{direction.to_s}")
    @i = 0
    @rx = 0
    @ry = 0
    self.z = 1
  end

  def x
    return super - @rx
  end

  def y
    return super - @ry
  end

  def update
    super
    if @i % 4 == 0
      oldx = self.x
      oldy = self.y
      case (@i / 4)
      when 1, 2, 3,  9, 10, 11,  17, 18
        if @direction == :up
          @ry += 2
        elsif @direction == :down
          @ry -= 2
        elsif @direction == :left
          @rx += 2
        elsif @direction == :right
          @rx -= 2
        end
      when 6, 7,  12, 13, 14,  21, 22, 23
        if @direction == :up
          @ry -= 2
        elsif @direction == :down
          @ry += 2
        elsif @direction == :left
          @rx -= 2
        elsif @direction == :right
          @rx += 2
        end
      end
      self.x = oldx + @rx
      self.y = oldy + @ry
    end
    @i += 1
    @i = 0 if @i > 92
  end
end
