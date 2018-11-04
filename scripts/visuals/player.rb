class Visuals
  class Player
    def self.create(game_player)
      $visuals.player = self.new(game_player)
    end

    # Publicly available for $game.player
    attr_reader :fake_anim

    def initialize(game_player)
      @game_player = game_player
      @sprite = Sprite.new($visuals.viewport)
      @sprite.bitmap = Bitmap.new("gfx/characters/" + game_player.graphic_name)
      @sprite.src_rect.width = @sprite.bitmap.width / 4
      @sprite.src_rect.height = @sprite.bitmap.height / 4
      @sprite.ox = @sprite.src_rect.width / 2
      @sprite.oy = @sprite.src_rect.height
      @sprite.x = Graphics.width / 2
      @sprite.y = Graphics.height / 2 + 16
      @sprite.z = 11 + 3 * (game_player.priority - 1)
      @oldx = game_player.x
      @oldy = game_player.y
      @xdist = []
      @xtrav = []
      @xstart = []
      @ydist = []
      @ytrav = []
      @ystart = []
      @anim = []
      @fake_anim = nil
      @stop_fake_anim = false
    end

    def set_direction(value)
      @sprite.src_rect.y = @sprite.src_rect.height * [:down,:left,:right,:up].index(value)
      @sprite.src_rect.x += @sprite.src_rect.width
      if @turncount
        @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
        @sprite.src_rect.x += @sprite.src_rect.width
        @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
      end
      @turncount = 6
    end

    def set_direction_noanim(value)
      @sprite.src_rect.y = @sprite.src_rect.height * [:down,:left,:right,:up].index(value)
    end

    def update
      moving = moving?
      # Executes the animation when turning
      if @turncount
        @turncount -= 1
        if @turncount == 0
          @turncount = nil
          @sprite.src_rect.x += @sprite.src_rect.width
          @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
        end
      end
      if @oldpriority != @game_player.priority
        @sprite.z = 11 + 3 * (@game_player.priority - 1)
      end
      # Executes the animation when moving against an impassable tile
      if @fake_anim
        @fake_anim -= 1 if @fake_anim > 0
        if @fake_anim == 0
          @sprite.src_rect.x += @sprite.src_rect.width
          if @sprite.src_rect.x.to_f / @sprite.bitmap.width * 4 % 2 == 1
            Audio.se_play("audio/se/wallbump.wav")
          end
          @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
          if @stop_fake_anim
            @fake_anim = nil
            @stop_fake_anim = false
            @sprite.src_rect.x += @sprite.src_rect.width if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 != 0
            @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
          else
            @fake_anim = 16
          end
        end
      end
      # Starts and stops the slower animation when moving against an impasasble tile
      if @oldfake_move != @game_player.fake_move
        if !@game_player.fake_move
          @stop_fake_anim = true
        else
          @fake_anim = 0
          @stop_fake_anim = false
        end
      end
      # Changes the sprite's bitmap if the player's graphic changed
      if @game_player.graphic_name != @oldgraphic
        frame_x = @sprite.src_rect.x.to_f / @sprite.bitmap.width * 4
        frame_y = @sprite.src_rect.y.to_f / @sprite.bitmap.height * 4
        @sprite.bitmap = Bitmap.new("gfx/characters/" + @game_player.graphic_name)
        @sprite.src_rect.width = @sprite.bitmap.width / 4
        @sprite.src_rect.height = @sprite.bitmap.height / 4
        @sprite.ox = @sprite.src_rect.width / 2
        @sprite.oy = @sprite.src_rect.height
        @sprite.src_rect.x = frame_x * @sprite.src_rect.width
        @sprite.src_rect.y = frame_y * @sprite.src_rect.height
      end
      # Add a horizontal movement to the move queue
      if @game_player.x != @oldx
        @xdist << 32 * (@game_player.x - @oldx)
        @xtrav << 0
        @xstart << (@xstart[0] ? @xstart.last + @xdist.last : $visuals.map.real_x)
        anims = []
        pos = @game_player.x - @oldx > 0
        (2 * (@game_player.x - @oldx).abs).times { |i| anims << 16 * i * (pos ? 1 : -1) }
        @anim << anims
        if @xtrav.size == 1
          @sprite.src_rect.x += @sprite.src_rect.width if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 != 0
          @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
        end
        @fake_anim = nil
        @stop_fake_anim = false
      end
      # Add a vertical movement to the move queue
      if @game_player.y != @oldy
        @ydist << 32 * (@game_player.y - @oldy)
        @ytrav << 0
        @ystart << (@ystart[0] ? @ystart.last + @ydist.last : $visuals.map.real_y)
        anims = []
        pos = @game_player.y - @oldy > 0
        (2 * (@game_player.y - @oldy).abs).times { |i| anims << 16 * i * (pos ? 1 : -1) }
        @anim << anims
        if @ytrav.size == 1
          @sprite.src_rect.x += @sprite.src_rect.width if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 != 0
          @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
        end
        @fake_anim = nil
        @stop_fake_anim = false
      end
      # Executes the horizontal movement
      if @xtrav[0] && @xdist[0]
        if @xtrav[0].abs < @xdist[0].abs
          dist = @game_player.speed * (@xdist[0] < 0 ? -1 : 1)
          @xtrav[0] += dist
          @xtrav[0] = @xdist[0] < 0 ? [@xtrav[0], @xdist[0]].max : [@xtrav[0], @xdist[0]].min
          if @anim[0].size > 0 && (@xdist[0] > 0 && @xtrav[0] > @anim[0][0] || @xdist[0] < 0 && @xtrav[0] < @anim[0][0])
            @sprite.src_rect.x += @sprite.src_rect.width
            @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
            @anim[0].delete_at(0)
          end
          $visuals.map.real_x = @xstart[0] - @xtrav[0]
        else
          @xtrav.delete_at(0)
          @xdist.delete_at(0)
          @xstart.delete_at(0)
          @anim.delete_at(0)
        end
      end
      # Executes the vertical movement
      if @ytrav[0] && @ydist[0]
        if @ytrav[0].abs < @ydist[0].abs
          dist = @game_player.speed * (@ydist[0] < 0 ? -1 : 1)
          @ytrav[0] += dist
          @ytrav[0] = @ydist[0] < 0 ? [@ytrav[0], @ydist[0]].max : [@ytrav[0], @ydist[0]].min
          if @anim[0].size > 0 && (@ydist[0] > 0 && @ytrav[0] > @anim[0][0] || @ydist[0] < 0 && @ytrav[0] < @anim[0][0])
            @sprite.src_rect.x += @sprite.src_rect.width
            @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
            @anim[0].delete_at(0)
          end
          $visuals.map.real_y = @ystart[0] - @ytrav[0]
        else
          @ytrav.delete_at(0)
          @ydist.delete_at(0)
          @ystart.delete_at(0)
          @anim.delete_at(0)
        end
      end
      # Stores old values for comparison in the next #update call
      @oldx = @game_player.x
      @oldy = @game_player.y
      @oldgraphic = @game_player.graphic_name
      @oldfake_move = @game_player.fake_move
      @oldpriority = @game_player.priority
    end

    def moving?
      return @ytrav[0] && @ydist[0] && @ytrav[0].abs < @ydist[0].abs || @xtrav[0] && @xdist[0] && @xtrav[0].abs < @xdist[0].abs
    end

    def moving_down?
      return moving? && @ydist[0] && @ydist[0] > 0
    end

    def moving_left?
      return moving? && @xdist[0] && @xdist[0] < 0
    end

    def moving_right?
      return moving? && @xdist[0] && @xdist[0] > 0
    end

    def moving_up?
      return moving? && @ydist[0] && @ydist[0] < 0
    end
  end
end