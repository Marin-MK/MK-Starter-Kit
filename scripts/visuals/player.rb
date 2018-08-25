class Visuals
  class Player
    def self.create(game_player)
      $visuals.player = self.new(game_player)
    end

    def initialize(game_player)
      @sprite = Sprite.new($visuals.viewport)
      @sprite.bitmap = Bitmap.new("gfx/characters/" + game_player.graphic_name)
      @sprite.src_rect.width = @sprite.bitmap.width / 4
      @sprite.src_rect.height = @sprite.bitmap.height / 4
      @sprite.z = 1
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
    end
  end
end