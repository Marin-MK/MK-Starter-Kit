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
      @parent.color = Color.new(0, 0, 0, 0)
      self.opacity = 0
      @done = false
      @i = 0
    end

    def done?
      return @done
    end

    def update
      super
      @i += 1
      if @i <= framecount(0.2)
        @parent.color.alpha += 32.0 / framecount(0.1) if @i <= framecount(0.1)
        self.opacity += 128.0 / framecount(0.2)
      elsif @i > framecount(0.6) && @i <= framecount(0.8)
        if self.bitmap
          self.bitmap.dispose
          self.bitmap = nil
        end
        @parent.color.alpha -= 32.0 / framecount(0.1) if @i > framecount(0.7)
        self.opacity -= 128.0 / framecount(0.2)
        @done = true if @i == framecount(0.8)
      end
      self.bitmap.dispose if self.bitmap
      self.bitmap = Bitmap.mask(@parent.bitmap, @src, Rect.new(@src_x, 0, 64, 64), 0, @y_offset % 64)
      @y_offset += @direction == :up ? 6 : -6
    end
  end
end
