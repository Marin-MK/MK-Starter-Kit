class Visuals
  class BaseCharacter
    # @return [Sprite] the actual sprite object.
    attr_accessor :sprite
    # @return [Boolean] whether the move route is ready for the next move command.
    attr_accessor :moveroute_ready
    # @return [Boolean] whether the current move route command is seen as "moving".
    attr_accessor :moveroute_moving_command

    def self.create(game_character)
      $b = self.new(game_character)
    end

    def initialize(game_character)
      @game_character = game_character
      @sprite = Sprite.new($visuals.viewport)
      @moveroute_ready = true
      @x_travelled = nil
      @x_destination = nil
      @y_travelled = nil
      @y_destination = nil
      @animate_count = 0
      @moveroute_wait = 0
      @moveroute_moving_command = false
      @relative_x = @game_character.x * 32 + @game_character.width * 16
      @relative_y = (@game_character.y + @game_character.height - 1) * 32 + 32
      @setdir = true
      @oldanimate_count = 0
    end

    def dispose
      @sprite.dispose
      @sprite = nil
    end

    def finish_movement
      return if @game_character.idle_animation || @sprite.bitmap.nil?
      next_frame if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 == 1
    end

    def direction_frame
      dir = @game_character.direction / 2 - 1
    end

    def move_down
      @y_travelled = 0
      @y_destination = 32
      @sprite.src_rect.y = direction_frame * @sprite.src_rect.height if @setdir
    end

    def move_left
      @x_travelled = 0
      @x_destination = -32
      @sprite.src_rect.y = direction_frame * @sprite.src_rect.height if @setdir
    end

    def move_right
      @x_travelled = 0
      @x_destination = 32
      @sprite.src_rect.y = direction_frame * @sprite.src_rect.height if @setdir
    end

    def move_up
      @y_travelled = 0
      @y_destination = -32
      @sprite.src_rect.y = direction_frame * @sprite.src_rect.height if @setdir
    end

    # @return [Boolean] whether the character is actually moving.
    def moving?
      return @moveroute_moving_command if !@moveroute_ready
      return !@x_travelled.nil? || !@x_destination.nil? || !@y_travelled.nil? || !@y_destination.nil?
    end

    def next_move
      @moveroute_ready = true
      @game_character.moveroute_next
    end

    def next_frame
      return if @sprite.bitmap.nil?
      @sprite.src_rect.x += @sprite.src_rect.width
      @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
    end

    # Sets the direction of the sprite without showing a subtle turn animation.
    # @param value [Integer, Symbol] the direction value.
    def set_direction_noanim(value)
      value = validate_direction(value)
      @game_character.instance_eval { @direction = value }
      @sprite.src_rect.y = direction_frame * @sprite.src_rect.height if @setdir
    end

    # Executes a move command.
    # @param command [Symbol, Array<Symbol>] the move command to execute.
    def execute_move_command(command)
      validate command => [Symbol, Array]
      command, args = command if command.is_a?(Array)
      case command
      when :down
        set_direction_noanim(2)
        @game_character.move_down
      when :left
        set_direction_noanim(4)
        @game_character.move_left
      when :right
        set_direction_noanim(6)
        @game_character.move_right
      when :up
        set_direction_noanim(8)
        @game_character.move_up
      when :turn_down
        set_direction_noanim(2)
        next_move
      when :turn_left
        set_direction_noanim(4)
        next_move
      when :turn_right
        set_direction_noanim(6)
        next_move
      when :turn_up
        set_direction_noanim(8)
        next_move
      when :turn_to_player
        @game_character.turn_to_player
        next_move
      when :wait
        finish_movement
        @moveroute_wait = args[:frames]
      else
        raise "Invalid move route command #{command.inspect}"
      end
      @moveroute_moving_command = [:down, :left, :right, :up].include?(command)
    end

    def update
      update_graphic if should_update_graphic
      update_direction if should_update_direction
      update_position if should_update_position
      update_moveroute if should_update_moveroute
      update_movement if should_update_movement
      update_animation if should_update_animation
    end

    def update_moveroute
      # Queues movement commands
      if @moveroute_wait > 0
        @moveroute_wait -= 1
        next_move if @moveroute_wait == 0
      end
      if @moveroute_ready
        move = @game_character.moveroute[0]
        if move
          @moveroute_ready = false
          name = move
          name = move[0] if move.is_a?(Array)
          execute_move_command(name)
        end
      end
    end

    def should_update_moveroute
      return true
    end

    def update_movement
      # Executes horizontal movement
      if @x_travelled && @x_destination && (@x_destination.abs - @x_travelled.abs) >= 0.01
        # Floating point precision movement
        pixels = 32.0 / (@game_character.speed * System.frame_rate) * (@x_destination <=> 0)
        old_x_travelled = @x_travelled
        @x_travelled += pixels
        @animate_count += pixels.abs
        if self.is_a?(Player)
          $visuals.map_renderer.move_horizontal(pixels)
        else
          @relative_x += pixels
        end
        # Account for overshooting the tile, due to rounding errors
        if (@x_destination.abs - @x_travelled.abs) < 0.01
          if self.is_a?(Player)
            $visuals.map_renderer.move_horizontal(@x_destination - @x_travelled)
          else
            @relative_x += @x_destination - @x_travelled
          end
          @x_travelled = nil
          @x_destination = nil
          next_move
          SystemEvent.trigger(:taken_step, @game_character.x, @game_character.y) if self.is_a?(Player)
        end
      end
      # Executes vertical movement
      if @y_travelled && @y_destination && (@y_destination.abs - @y_travelled.abs) >= 0.01
        # Floating point precision movement
        pixels = 32.0 / (@game_character.speed * System.frame_rate) * (@y_destination <=> 0)
        old_x_travelled = @y_travelled
        @y_travelled += pixels
        @animate_count += pixels.abs
        if self.is_a?(Player)
          $visuals.map_renderer.move_vertical(pixels)
        else
          @relative_y += pixels
        end
        # Account for overshooting the tile, due to rounding errors
        if (@y_destination.abs - @y_travelled.abs) < 0.01
          if self.is_a?(Player)
            $visuals.map_renderer.move_vertical(@y_destination - @y_travelled)
          else
            @relative_y += @y_destination - @y_travelled
          end
          @y_travelled = nil
          @y_destination = nil
          next_move
          SystemEvent.trigger(:taken_step, @game_character.x, @game_character.y) if self.is_a?(Player)
        end
      end
    end

    def should_update_movement
      return true
    end

    def update_animation
      # Animates the sprite.
      idle = !@game_character.moving? && !@game_character.was_moving?
      idle = false if @game_character.is_a?(Game::Player) && !@game_character.input_possible?
      idle = false if !@game_character.idle_animation
      speed = @game_character.speed
      if idle
        pixels = 32.0 / (@game_character.idle_speed * System.frame_rate)
        @animate_count += pixels.abs
        speed = @game_character.idle_speed
      end
      if 32.0 / (speed * System.frame_rate) > @game_character.animation_speed && @oldanimate_count != @animate_count ||
         @oldanimate_count % @game_character.animation_speed > @animate_count % @game_character.animation_speed
        next_frame
      end
      @oldanimate_count = @animate_count
    end

    def should_update_animation
      return true
    end

    def update_graphic
      # Changes the sprite's bitmap if the player's graphic changed
      frame_x = @sprite.bitmap ? (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4).round : 0
      frame_y = @sprite.bitmap ? (@sprite.src_rect.y.to_f / @sprite.bitmap.height * 4).round : @game_character.direction / 2 - 1
      @sprite.set_bitmap("gfx/characters/" + @game_character.graphic_name)
      @sprite.src_rect.width = @sprite.bitmap.width / 4
      @sprite.src_rect.height = @sprite.bitmap.height / 4
      @sprite.ox = @sprite.src_rect.width / 2
      @sprite.oy = @sprite.src_rect.height
      @sprite.src_rect.x = frame_x * @sprite.src_rect.width
      @sprite.src_rect.y = frame_y * @sprite.src_rect.height
    end

    def should_update_graphic
      ret = @oldgraphic != @game_character.graphic_name
      @oldgraphic = @game_character.graphic_name
      return ret
    end

    def update_direction
      # Refreshes if the direction changed
      @sprite.src_rect.y = (@game_character.direction / 2 - 1) * @sprite.src_rect.height
    end

    def should_update_direction
      ret = @olddirection != @game_character.direction && @setdir
      @olddirection = @game_character.direction
      return ret
    end

    def update_position
      # Sets the sprite's on-screen location based on the map's offset and the coordinates of the sprite relative to the map.
      map = $visuals.maps[@game_character.map_id]
      @sprite.x = (map.x + @relative_x).round
      @sprite.y = (map.y + @relative_y).round
      @sprite.z = @sprite.y + 31
    end

    def should_update_position
      return true
    end
  end
end
