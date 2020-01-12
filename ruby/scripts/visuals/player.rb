class Visuals
  # The visual component of Game::Player objects.
  class Player
    # Creates a new player sprite linked to the player object.
    # @param game_player [Game::Player] the player object.
    def self.create(game_player)
      $visuals.player = self.new(game_player)
    end

    # Creates a new Player object.
    def initialize(game_player)
      @game_player = game_player
      @sprite = Sprite.new($visuals.viewport)
      @sprite.set_bitmap("gfx/characters/" + game_player.graphic_name)
      @sprite.src_rect.width = @sprite.bitmap.width / 4
      @sprite.src_rect.height = @sprite.bitmap.height / 4
      @sprite.src_rect.y = @sprite.src_rect.height * (@game_player.direction / 2 - 1)
      @sprite.ox = @sprite.src_rect.width / 2
      @sprite.oy = @sprite.src_rect.height
      @sprite.x = Graphics.width / 2
      @sprite.y = Graphics.height / 2 + 16
      @sprite.z = @sprite.y + 31
      @oldx = @game_player.global_x
      @oldy = @game_player.global_y
      @xdist = []
      @xtrav = []
      @xstart = []
      @xloc = []
      @ydist = []
      @ytrav = []
      @ystart = []
      @yloc = []
      @anim = []
      @fake_anim = nil
      @stop_fake_anim = false
    end

    def dispose
      @sprite.dispose
      @sprite = nil
    end

    # Sets the direction of the sprite.
    # @param value [Integer, Symbol] the direction value.
    def set_direction(value)
      value = validate_direction(value)
      @sprite.src_rect.y = @sprite.src_rect.height * (value / 2 - 1)
      @sprite.src_rect.x += @sprite.src_rect.width
      if @turncount
        @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
        @sprite.src_rect.x += @sprite.src_rect.width
        @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
      end
      @turncount = 6
    end

    # Sets the direction of the sprite without showing a subtle turn animation.
    # @param value [Integer, Symbol] the direction value.
    def set_direction_noanim(value)
      value = validate_direction(value)
      @sprite.src_rect.y = @sprite.src_rect.height * (value / 2 - 1)
    end

    # Updates the player sprite and performs movement.
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
      @sprite.z = @sprite.y + 31
      # Executes the animation when moving against an impassable tile
      if @fake_anim
        @fake_anim -= 1 if @fake_anim > 0
        if @fake_anim == 0
          @sprite.src_rect.x += @sprite.src_rect.width
          play = false
          if @sprite.src_rect.x.to_f / @sprite.bitmap.width * 4 % 2 == 1
            play = true
          end
          @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
          if @stop_fake_anim
            @fake_anim = nil
            @stop_fake_anim = false
            @sprite.src_rect.x += @sprite.src_rect.width if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 != 0
            @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
          else
            @fake_anim = 16
            Audio.se_play("audio/se/wallbump.wav") if play
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
        @sprite.set_bitmap("gfx/characters/" + @game_player.graphic_name)
        @sprite.src_rect.width = @sprite.bitmap.width / 4
        @sprite.src_rect.height = @sprite.bitmap.height / 4
        @sprite.ox = @sprite.src_rect.width / 2
        @sprite.oy = @sprite.src_rect.height
        @sprite.src_rect.x = frame_x * @sprite.src_rect.width
        @sprite.src_rect.y = frame_y * @sprite.src_rect.height
      end
      # Add horizontal movement to the move queue
      if @game_player.global_x != @oldx && !@skip_movement
        @xdist << 32 * (@game_player.global_x - @oldx)
        @xtrav << 0
        @xloc << @game_player.global_x
        h = {}
        if @xstart[0]
          @xstart.last.each_key { |k| h[k] = @xstart.last[k] - @xdist.last }
        else
          $visuals.maps.each_key { |k| h[k] = $visuals.maps[k].real_x }
        end
        @xstart << h
        anims = []
        pos = @game_player.global_x - @oldx > 0
        aframes = 2
        (aframes * (@game_player.global_x - @oldx).abs).times { |i| anims << (32.0 / aframes) * i * (pos ? 1 : -1) }
        @anim << anims
        if @xtrav.size == 1
          @sprite.src_rect.x += @sprite.src_rect.width if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 != 0
          @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
        end
        @fake_anim = nil
        @stop_fake_anim = false
      end
      # Add vertical movement to the move queue
      if @game_player.global_y != @oldy && !@skip_movement
        @ydist << 32 * (@game_player.global_y - @oldy)
        @ytrav << 0
        @yloc << @game_player.global_y
        h = {}
        if @ystart[0]
          @ystart.last.each_key { |k| h[k] = @ystart.last[k] - @ydist.last }
        else
          $visuals.maps.each_key { |k| h[k] = $visuals.maps[k].real_y }
        end
        @ystart << h
        anims = []
        pos = @game_player.global_y - @oldy > 0
        aframes = 2
        (aframes * (@game_player.global_y - @oldy).abs).times { |i| anims << (32.0 / aframes) * i * (pos ? 1 : -1) }
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
          oldtrav = @xtrav[0]
          @xtrav[0] += dist
          @xtrav[0] = @xdist[0] < 0 ? [@xtrav[0], @xdist[0]].max : [@xtrav[0], @xdist[0]].min
          if @anim[0].size > 0 && (@xdist[0] > 0 && @xtrav[0] > @anim[0][0] || @xdist[0] < 0 && @xtrav[0] < @anim[0][0])
            @sprite.src_rect.x += @sprite.src_rect.width
            @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
            @anim[0].delete_at(0)
          end
          $visuals.maps.values.each { |m| m.real_x = @xstart[0][m.id] - @xtrav[0] }
          $visuals.map_renderer.move_x(@xtrav[0] - oldtrav)
        else # Movement completed
          @xtrav.delete_at(0)
          @xdist.delete_at(0)
          @xstart.delete_at(0)
          x = @xloc[0]
          y = @yloc[0] || @game_player.global_y
          SystemEvent.trigger(:taken_step, *$game.map.global_to_local(x, y))
          @xloc.delete_at(0)
          @anim.delete_at(0)
        end
      end
      # Executes the vertical movement
      if @ytrav[0] && @ydist[0]
        if @ytrav[0].abs < @ydist[0].abs
          dist = @game_player.speed * (@ydist[0] < 0 ? -1 : 1)
          oldtrav = @ytrav[0]
          @ytrav[0] += dist
          @ytrav[0] = @ydist[0] < 0 ? [@ytrav[0], @ydist[0]].max : [@ytrav[0], @ydist[0]].min
          if @anim[0].size > 0 && (@ydist[0] > 0 && @ytrav[0] > @anim[0][0] || @ydist[0] < 0 && @ytrav[0] < @anim[0][0])
            @sprite.src_rect.x += @sprite.src_rect.width
            @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
            @anim[0].delete_at(0)
          end
          $visuals.maps.values.each { |m| m.real_y = @ystart[0][m.id] - @ytrav[0] }
          $visuals.map_renderer.move_y(@ytrav[0] - oldtrav)
        else
          @ytrav.delete_at(0)
          @ydist.delete_at(0)
          @ystart.delete_at(0)
          x = @xloc[0] || @game_player.global_x
          y = @yloc[0]
          SystemEvent.trigger(:taken_step, *$game.map.global_to_local(x, y))
          @yloc.delete_at(0)
          @anim.delete_at(0)
        end
      end
      # Stores old values for comparison in the next #update call
      @oldx = @game_player.global_x
      @oldy = @game_player.global_y
      @oldgraphic = @game_player.graphic_name
      @oldfake_move = @game_player.fake_move
      @skip_movement = false if @skip_movement
    end

    def skip_movement
      @skip_movement = true
    end

    # Moves the screen without animation.
    def move(xdiff, ydiff, xtilediff, ytilediff)
      if xtilediff != 0
        xdiff *= 32
        $visuals.maps.values.each { |m| m.real_x -= xtilediff * 32 }
        $visuals.map_renderer.move_x(xdiff)
      end
      if ytilediff != 0
        ydiff *= 32
        $visuals.maps.values.each { |m| m.real_y -= ytilediff * 32 }
        $visuals.map_renderer.move_y(ydiff)
      end
      skip_movement
    end

    # @return [Boolean] whether or not the player is moving.
    def moving?
      return @ytrav[0] && @ydist[0] && @ytrav[0].abs < @ydist[0].abs || @xtrav[0] && @xdist[0] && @xtrav[0].abs < @xdist[0].abs
    end

    attr_reader :fake_anim
  end
end
