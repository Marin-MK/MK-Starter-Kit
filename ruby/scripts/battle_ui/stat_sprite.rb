class Battle
  class StatSprite < Sprite
    def initialize(viewport, parent, stat_type, direction)
      super(viewport)
      @src = Bitmap.new("gfx/ui/battle/stat_#{stat_type}")
      @src_x = direction == :up ? 0 : 64
      @direction = direction
      @y_offset = 0
      @parent = parent
      self.x = @parent.x
      self.y = @parent.y
      self.z = @parent.z + 1
      self.bitmap = Bitmap.new(@parent.src_rect.width, @parent.src_rect.height)
      self.bitmap.fill_rect(0, 0, 20, 20, Color.new(255, 0, 0))
    end

    def update
      super
      self.bitmap.clear
      for y in 0...@parent.src_rect.height
        if y == @parent.src_rect.height / 2
          Graphics.update
        end
        for x in 0...@parent.src_rect.width
          color = @parent.bitmap.get_pixel(@parent.src_rect.x + x, @parent.src_rect.y + y)
          next if color.alpha == 0
          self.bitmap.set_pixel(x, y, @src.get_pixel(@src_x + x % 64, (y - @y_offset) % 64))
        end
      end
      @y_offset += 1
    end
  end
end
