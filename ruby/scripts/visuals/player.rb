class Visuals
  # The visual component of Game::Player objects.
  class Player < BaseCharacter
    # Creates a new player sprite linked to the player object.
    # @param game_player [Game::Player] the player object.
    def self.create(game_player)
      $visuals.player = self.new(game_player)
    end

    attr_reader :fake_anim

    # Creates a new Player object.
    def initialize(game_player)
      super(game_player)
      @game_player = game_player
      @sprite.set_bitmap("gfx/characters/" + @game_player.graphic_name)
      @sprite.src_rect.width = @sprite.bitmap.width / 4
      @sprite.src_rect.height = @sprite.bitmap.height / 4
      @sprite.src_rect.y = @sprite.src_rect.height * (@game_player.direction / 2 - 1)
      @sprite.ox = @sprite.src_rect.width / 2
      @sprite.oy = @sprite.src_rect.height@game_player
      @sprite.x = Graphics.width / 2
      @sprite.y = Graphics.height / 2 + 16
      @fake_anim = nil
      @stop_fake_anim = false
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

    def move_down
      super
      @fake_anim = nil
      @stop_fake_anim = false
    end

    def move_left
      super
      @fake_anim = nil
      @stop_fake_anim = false
    end

    def move_right
      super
      @fake_anim = nil
      @stop_fake_anim = false
    end

    def move_up
      super
      @fake_anim = nil
      @stop_fake_anim = false
    end

    # Moves the screen without animation.
    def move(xdiff, ydiff, xtilediff, ytilediff)
      raise "$visuals.player.move error"
      if xtilediff != 0
        xdiff *= 32
        $visuals.maps.each_value { |m| m.real_x -= xtilediff * 32 }
        $visuals.map_renderer.move_x(xdiff)
      end
      if ytilediff != 0
        ydiff *= 32
        $visuals.maps.each_value { |m| m.real_y -= ytilediff * 32 }
        $visuals.map_renderer.move_y(ydiff)
      end
    end

    # Updates the player sprite and performs movement.
    def update
      super
      update_turn_animation if should_update_turn_animation
      update_fake_movement if should_update_fake_movement
    end

    def should_update_direction
      # Direction updates happen directly via Game::Player
      return false
    end

    def update_turn_animation
      # Executes the animation when turning
      @turncount -= 1
      if @turncount == 0
        @turncount = nil
        @sprite.src_rect.x += @sprite.src_rect.width
        @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
      end
    end

    def should_update_turn_animation
      return @turncount
    end

    def update_fake_movement
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
      @oldfake_move = @game_player.fake_move
    end

    def should_update_fake_movement
      return true
    end

    def update_position
      # Player only changes z
      @sprite.z = @sprite.y + 31
    end
  end
end
