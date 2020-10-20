class Battle
  class BallOpenAnimation
    # Create a new ball opening animation.
    # @param battler_sprite [BattlerSprite] the battler that appeared out of the ball.
    # @param viewport [Viewport] the viewport of the animation sprites.
    def initialize(battler_sprite, viewport = nil)
      validate \
          battler_sprite => BattlerSprite,
          viewport => [NilClass, Viewport]
      @viewport = viewport
      @battler_sprite = battler_sprite
      @particles = []
      # Create the particles.
      create_particles
      @i = 0
      @interval = 0.1
      @disposed = false
    end

    # Creates the particles used in the animation.
    def create_particles
      @particles << PokeballOpenParticle.new(0.35, -4, -4, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 0, -5, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 4, -4, @battler_sprite.x, 232, @viewport)
    end

    # Updates the particles.
    def update
      @particles.each(&:update)
      if @i && @i > framecount(@interval)
        create_particles
        @i = nil
      end
      @i += 1 if @i
      dispose if @particles.all?(:disposed?)
    end

    # Disposes all particles.
    def dispose
      @particles.each { |e| e.dispose if !e.disposed? }
      @disposed = true
    end

    # @return [Boolean] whether the animation has been disposed.
    def disposed?
      return @disposed
    end
  end

  class BallCloseAnimation < BallOpenAnimation
    # Creates the particles used in the animation.
    def create_particles
      @particles << PokeballOpenParticle.new(0.35, -4, -4, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 0, -5, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 4, -4, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, -4, 0, @battler_sprite.x, 216, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 4, 0, @battler_sprite.x, 216, @viewport)
    end
  end

  class PokeballOpenParticle < Sprite
    # Creates a ball open particle.
    # @param lifetime [Float] the time in seconds this particle lives.
    # @param xspeed [Float] the number of pixels to move each frame horizontally.
    # @param yspeed [Float] the number of pixels to move each frame vertically.
    # @param x [Float] the starting x position of the particle.
    # @param y [Float] the startiing y position of the particle.
    # @param viewport [NilClass, Viewport] the viewport of the particle sprite.
    def initialize(lifetime, xspeed, yspeed, x, y, viewport = nil)
      validate \
          lifetime => Float,
          xspeed => Float,
          yspeed => Float,
          x => Float,
          y => Float,
          viewport => [NilClass, Viewport]
      super(viewport)
      self.bitmap = Bitmap.new(14, 6)
      self.bitmap.fill_rect(0, 0, 14, 3, Color.new(248, 168, 0))
      self.bitmap.fill_rect(0, 3, 14, 3, Color.new(248, 248, 248))
      self.ox = 6
      self.oy = 3
      self.z = 1
      @xspeed = xspeed
      @yspeed = yspeed
      self.x = x
      self.y = y
      @i = 0
      @lifetime = lifetime
    end

    # Update the particle and dispose when its lifetime has expired.
    def update
      return if disposed?
      super
      @i += 1
      self.x += @xspeed
      self.y += @yspeed
      self.angle -= 45
      if @i >= framecount(@lifetime)
        dispose
      end
    end
  end
end
