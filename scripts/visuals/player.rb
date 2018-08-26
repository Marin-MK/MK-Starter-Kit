class Visuals
  class Player
    def self.create(game_player)
      $visuals.player = self.new(game_player)
    end

    attr_accessor :sprite
    attr_accessor :ytrav
    attr_accessor :ydist

    def initialize(game_player)
      @sprite = Sprite.new($visuals.viewport)
      @sprite.bitmap = Bitmap.new("gfx/characters/" + game_player.graphic_name)
      @sprite.src_rect.width = @sprite.bitmap.width / 4
      @sprite.src_rect.height = @sprite.bitmap.height / 4
      @sprite.z = 1
      @sprite.ox = @sprite.src_rect.width / 2
      @sprite.oy = @sprite.src_rect.height
      @sprite.x = 16
      @sprite.y = 32
      @oldx = game_player.x
      @oldy = game_player.y
      @xdist = []
      @xtrav = []
      @xstart = []
      @ydist = []
      @ytrav = []
      @ystart = []
    end

    def set_direction(value)
      @sprite.src_rect.y = @sprite.src_rect.height * [:down,:left,:right,:up].index(value)
      @sprite.src_rect.x += @sprite.src_rect.width
      if @turncount
        @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
        @sprite.src_rect.x += @sprite.src_rect.width
      end
      @turncount = 5
    end

    def update
      if @turncount
        @turncount -= 1
        if @turncount == 0
          @turncount = nil
          @sprite.src_rect.x += @sprite.src_rect.width
          @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
        end
      end
      if @oldx != $game.player.x
        @xdist << 32 * ($game.player.x - @oldx)
        @xtrav << 0
        @xstart << (@xstart[0] ? @xstart.last + @xdist.last : @sprite.x)
      end
      if @oldy != $game.player.y
        @ydist << 32 * ($game.player.y - @oldy)
        @ytrav << 0
        @ystart << (@ystart[0] ? @ystart.last + @ydist.last : @sprite.y)
      end
      if @xtrav[0] && @xdist[0]
        if @xtrav[0].abs < @xdist[0].abs
          dist = $game.player.speed * (@xdist[0] < 0 ? -1 : 1)
          @xtrav[0] += dist
          @xtrav[0] = @xdist[0] < 0 ? [@xtrav[0], @xdist[0]].max : [@xtrav[0], @xdist[0]].min
          @sprite.x = @xstart[0] + @xtrav[0]
        else
          @xtrav.delete_at(0)
          @xdist.delete_at(0)
          @xstart.delete_at(0)
        end
      end
      if @ytrav[0] && @ydist[0]
        if @ytrav[0].abs < @ydist[0].abs
          dist = $game.player.speed * (@ydist[0] < 0 ? -1 : 1)
          @ytrav[0] += dist
          @ytrav[0] = @ydist[0] < 0 ? [@ytrav[0], @ydist[0]].max : [@ytrav[0], @ydist[0]].min
          @sprite.y = @ystart[0] + @ytrav[0]
        else
          @ytrav.delete_at(0)
          @ydist.delete_at(0)
          @ystart.delete_at(0)
        end
      end
      @oldx = $game.player.x
      @oldy = $game.player.y
    end

    def moving?
      return @ytrav[0] && @ydist[0] && @ytrav[0].abs < @ydist[0].abs || @xtrav[0] && @xdist[0] && @xtrav[0].abs < @xdist[0].abs
    end

    def moving_down?
      return moving? && @ydist[0] && @ydist[0] > 0
    end

    def moving_left?
      return moving? && @xdist[0] && @xdist[0] > 0
    end

    def moving_right?
      return moving? && @xdist[0] && @xdist[0] < 0
    end

    def moving_up?
      return moving? && @ydist[0] && @ydist[0] < 0
    end
  end
end