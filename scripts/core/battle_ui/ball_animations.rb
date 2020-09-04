class Battle
  class PokeballOpenParticle < Sprite
    def initialize(lifetime, xspeed, yspeed, x, y, viewport = nil)
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

  class BallOpenAnimation
    def initialize(battler_sprite, viewport = nil)
      @viewport = viewport
      @battler_sprite = battler_sprite
      @particles = []
      create_particles
      @i = 0
      @interval = 0.1
      @disposed = false
    end

    def create_particles
      @particles << PokeballOpenParticle.new(0.35, -4, -4, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 0, -5, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 4, -4, @battler_sprite.x, 232, @viewport)
    end

    def update
      @particles.each(&:update)
      if @i && @i > framecount(@interval)
        create_particles
        @i = nil
      end
      @i += 1 if @i
      dispose if @particles.all?(:disposed?)
    end

    def dispose
      @particles.each { |e| e.dispose if !e.disposed? }
      @disposed = true
    end

    def disposed?
      return @disposed
    end
  end

  class BallCloseAnimation < BallOpenAnimation
    def create_particles
      @particles << PokeballOpenParticle.new(0.35, -4, -4, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 0, -5, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 4, -4, @battler_sprite.x, 232, @viewport)
      @particles << PokeballOpenParticle.new(0.35, -4, 0, @battler_sprite.x, 216, @viewport)
      @particles << PokeballOpenParticle.new(0.35, 4, 0, @battler_sprite.x, 216, @viewport)
    end
  end
end
