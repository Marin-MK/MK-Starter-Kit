class Battle
  class BallOpenAnimation
    def initialize(battler_sprite, viewport = nil)
      @viewport = viewport
      @battler_sprite = battler_sprite
      @particles = []
      create_particles
      @i = 0
      @disposed = false
    end

    def create_particles
      @particles << PokeballOpenParticle.new(4, true, false, @battler_sprite.x, @battler_sprite.y, @viewport)
      @particles << PokeballOpenParticle.new(5, false, false, @battler_sprite.x, @battler_sprite.y, @viewport)
      @particles << PokeballOpenParticle.new(4, false, true, @battler_sprite.x, @battler_sprite.y, @viewport)
    end

    def update
      @particles.each(&:update)
      if @i && @i > framecount(0.1)
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

    class PokeballOpenParticle < Sprite
      def initialize(speed, left, right, x, y, viewport = nil)
        super(viewport)
        self.bitmap = Bitmap.new(14, 6)
        self.bitmap.fill_rect(0, 0, 14, 3, Color.new(248, 168, 0))
        self.bitmap.fill_rect(0, 3, 14, 3, Color.new(248, 248, 248))
        self.ox = 6
        self.oy = 3
        self.z = 1
        @left = left
        @right = right
        @speed = speed
        self.x = x
        self.y = y
        @i = 0
      end

      def update
        return if disposed?
        super
        @i += 1
        self.x += @left ? -@speed : @right ? @speed : 0
        self.y -= @speed
        self.angle -= 45
        if @i >= framecount(0.3)
          dispose
        end
      end
    end
  end
end
