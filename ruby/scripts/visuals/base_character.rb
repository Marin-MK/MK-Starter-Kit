class Visuals
  class BaseCharacter
    # @return [Sprite] the actual sprite object.
    attr_accessor :sprite
    # @return [Boolean] whether the move route is ready for the next move command.
    attr_accessor :moveroute_ready
    # @return [Boolean] whether the current move route command is seen as "moving".
    attr_accessor :moveroute_moving_command

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
      @setdir = true
    end

    def dispose
      @sprite.dispose
      @sprite = nil
    end

    def finish_movement
      next_frame if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 == 1
    end

    def move_down
      @y_travelled = 0
      @y_destination = 32
      @sprite.src_rect.y = (@game_character.direction / 2 - 1) * @sprite.src_rect.height if @setdir
    end

    def move_left
      @x_travelled = 0
      @x_destination = -32
      @sprite.src_rect.y = (@game_character.direction / 2 - 1) * @sprite.src_rect.height if @setdir
    end

    def move_right
      @x_travelled = 0
      @x_destination = 32
      @sprite.src_rect.y = (@game_character.direction / 2 - 1) * @sprite.src_rect.height if @setdir
    end

    def move_up
      @y_travelled = 0
      @y_destination = -32
      @sprite.src_rect.y = (@game_character.direction / 2 - 1) * @sprite.src_rect.height if @setdir
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
      @sprite.src_rect.y = @sprite.src_rect.height * (value / 2 - 1) if @setdir
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
      old_animate_count = @animate_count
      # Queues movement commands
      if !moving?
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
      # Executes horizontal movement
      if @x_travelled && @x_destination && (@x_destination.abs - @x_travelled.abs) >= 0.01
        # Floating point precision movement
        pixels = 32.0 / (@game_character.speed * Graphics.frame_rate) * (@x_destination <=> 0)
        old_x_travelled = @x_travelled
        @x_travelled += pixels
        @animate_count += pixels.abs
        if self.is_a?(Player)
          $visuals.map_renderer.move_horizontal(pixels)
        else
          @relative_x += pixels
        end
        if (@x_destination.abs - @x_travelled.abs) < 0.01
          # Account for overshooting the tile, due to rounding errors
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
        pixels = 32.0 / (@game_character.speed * Graphics.frame_rate) * (@y_destination <=> 0)
        old_x_travelled = @y_travelled
        @y_travelled += pixels
        @animate_count += pixels.abs
        if self.is_a?(Player)
          $visuals.map_renderer.move_vertical(pixels)
        else
          @relative_y += pixels
        end
        if (@y_destination.abs - @y_travelled.abs) < 0.01
          # Account for overshooting the tile, due to rounding errors
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
      # Animates the sprite.
      if 32.0 / (@game_character.speed * Graphics.frame_rate) > @game_character.frame_update_interval && old_animate_count != @animate_count ||
         old_animate_count % @game_character.frame_update_interval > @animate_count % @game_character.frame_update_interval
        next_frame
      end
      @sprite.z = @sprite.y + 31
    end
  end
end
