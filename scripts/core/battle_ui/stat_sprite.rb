class Battle
  class StatSprite < Sprite
    # Creates a new stat up/down sprite to mask over a battler.
    # @param viewport [Viewport] the viewport of the sprite.
    # @param parent [Sprite] the sprite to mask over.
    # @param stat_type [Symbol] the color of the stat.
    # @param direction [Symbol] the direction of animation.
    def initialize(viewport, parent, stat_type, direction)
      validate \
          viewport => [NilClass, Viewport],
          parent => Sprite,
          stat_type => Symbol,
          direction => Symbol
      super(viewport)
      # Load the source bitmap
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

    # @return [Boolean] whether the animation is done.
    def done?
      return @done
    end

    # Updates the animation.
    def update
      super
      @i += 1
      if @i <= framecount(0.2)
        # Fade the mask in.
        @parent.color.alpha += 32.0 / framecount(0.1) if @i <= framecount(0.1)
        self.opacity += 128.0 / framecount(0.2)
      elsif @i > framecount(0.6) && @i <= framecount(0.8)
        if self.bitmap
          self.bitmap.dispose
          self.bitmap = nil
        end
        # Fade the mask out.
        @parent.color.alpha -= 32.0 / framecount(0.1) if @i > framecount(0.7)
        self.opacity -= 128.0 / framecount(0.2)
        @done = true if @i == framecount(0.8)
      end
      self.bitmap.dispose if self.bitmap
      # Mask the source bitmap with the parent bitmap.
      self.bitmap = Bitmap.mask(@parent.bitmap, @src, Rect.new(@src_x, 0, 64, 64), 0, @y_offset % 64)
      @y_offset += @direction == :up ? 6 : -6
    end
  end
end
