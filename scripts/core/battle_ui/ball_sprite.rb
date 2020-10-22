class Battle
  class BallSprite < Sprite
    # Creates a new thrown all sprite. Isolated due to the math of its arc.
    def initialize(ball_used, viewport = nil)
      validate \
          ball_used => Symbol,
          viewport => [NilClass, Viewport]
      super(viewport)
      self.bitmap = Bitmap.new("gfx/ui/battle/ball")
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2
      @i = 95
    end

    # Update the positioning and spin of the ball.
    def update
      @rx ||= self.x
      @ry ||= self.y

      # Standard 2nd degree parabolic formula for the ball trajectory
      a = 1 / 12.0
      b = -19
      c = 1200
      x = @i
      y = a * (x ** 2) + b * x + c

      self.x = x
      self.y = y
      self.angle += 35
      if @i >= 110 && @i < 124
        # Float in the air a little longer around the top
        @i += 0.75
      else
        @i += 2
      end
      if @i >= 155
        dispose
      end
    end

    # @return [Boolean] whether the animation is close the done.
    def almost_done?
      return @i >= 148
    end
  end
end
