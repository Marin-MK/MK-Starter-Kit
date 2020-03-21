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
      @x_travelled = nil
      @x_destination = nil
      @y_travelled = nil
      @y_destination = nil
      @animate_count = 0
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
        next_frame
      end
      @turncount = 6
    end

    # Sets the direction of the sprite without showing a subtle turn animation.
    # @param value [Integer, Symbol] the direction value.
    def set_direction_noanim(value)
      value = validate_direction(value)
      @sprite.src_rect.y = @sprite.src_rect.height * (value / 2 - 1)
    end

    def move_down
      @y_travelled = 0
      @y_destination = 32
      @fake_anim = nil
      @stop_fake_anim = false
    end

    def move_left
      @x_travelled = 0
      @x_destination = -32
      @fake_anim = nil
      @stop_fake_anim = false
    end

    def move_right
      @x_travelled = 0
      @x_destination = 32
      @fake_anim = nil
      @stop_fake_anim = false
    end

    def move_up
      @y_travelled = 0
      @y_destination = -32
      @fake_anim = nil
      @stop_fake_anim = false
    end

    # Updates the player sprite and performs movement.
    def update
      old_animate_count = @animate_count
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
        frame_x = (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4).round
        frame_y = (@sprite.src_rect.y.to_f / @sprite.bitmap.height * 4).round
        @sprite.set_bitmap("gfx/characters/" + @game_player.graphic_name)
        @sprite.src_rect.width = @sprite.bitmap.width / 4
        @sprite.src_rect.height = @sprite.bitmap.height / 4
        @sprite.ox = @sprite.src_rect.width / 2
        @sprite.oy = @sprite.src_rect.height
        @sprite.src_rect.x = frame_x * @sprite.src_rect.width
        @sprite.src_rect.y = frame_y * @sprite.src_rect.height
      end
      # Executes horizontal movement
      if @x_travelled && @x_destination && @x_travelled.abs < @x_destination.abs
        # Floating point precision movement
        pixels = @game_player.speed * (@x_destination <=> 0)
        old_x_travelled = @x_travelled
        @x_travelled += pixels
        @animate_count += pixels.abs
        $visuals.map_renderer.move_horizontal(pixels)
        if @x_travelled.abs >= @x_destination.abs
          # Account for overshooting the tile, due to rounding errors
          $visuals.map_renderer.move_horizontal(@x_destination - @x_travelled)
          @x_travelled = nil
          @x_destination = nil
          SystemEvent.trigger(:taken_step, @game_player.x, @game_player.y)
        end
      end
      # Executes vertical movement
      if @y_travelled && @y_destination && @y_travelled.abs < @y_destination.abs
        # Floating point precision movement
        pixels = @game_player.speed * (@y_destination <=> 0)
        old_y_travelled = @y_travelled
        @y_travelled += pixels
        @animate_count += pixels.abs
        $visuals.map_renderer.move_vertical(pixels)
        if @y_travelled.abs >= @y_destination.abs
          # Account for overshooting the tile, due to rounding errors
          $visuals.map_renderer.move_vertical(@y_destination - @y_travelled)
          @y_travelled = nil
          @y_destination = nil
          SystemEvent.trigger(:taken_step, @game_player.x, @game_player.y)
        end
      end
      if @game_player.speed > @game_player.frame_update_interval ||
         old_animate_count % @game_player.frame_update_interval > @animate_count % @game_player.frame_update_interval
        next_frame
      end
      # Stores old values for comparison in the next #update call
      @oldgraphic = @game_player.graphic_name
      @oldfake_move = @game_player.fake_move
      @skip_movement = false if @skip_movement
    end

    def next_frame
      @sprite.src_rect.x += @sprite.src_rect.width
      @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
    end

    def finish_movement
      next_frame if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 == 1
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
      return !@x_travelled.nil? || !@x_destination.nil? || !@y_travelled.nil? || !@y_destination.nil?
    end

    attr_reader :fake_anim
  end
end
