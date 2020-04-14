class Visuals
  # The visual component of Game::Event objects.
  class Event
    # Creates a new sprite linked to the event object.
    # @param game_event [Game::Event] the event object.
    def self.create(game_event)
      $visuals.maps[game_event.map_id].events[game_event.id] = self.new(game_event)
    end

    # @return [Sprite] the actual sprite object.
    attr_accessor :sprite
    # @return [Integer] the x position of this event relative to the map.
    attr_accessor :relative_x
    # @return [Integer] the y position of this event relative to the map.
    attr_accessor :relative_y
    # @return [Boolean] whether the move route is ready for the next move command.
    attr_accessor :moveroute_ready
    # @return [Boolean] whether the current move route command is seen as "moving".
    attr_accessor :moveroute_moving_command

    # Creates a new sprite for the event object.
    def initialize(game_event)
      @game_event = game_event
      @sprite = Sprite.new($visuals.viewport)
      @sprite.z = 10 + 3 * @game_event.settings.priority
      @moveroute_ready = true
      @x_travelled = nil
      @x_destination = nil
      @y_travelled = nil
      @y_destination = nil
      @animate_count = 0
      @relative_x = @game_event.x * 32 + 16
      @relative_y = @game_event.y * 32 + 32
      @moveroute_wait = 0
      @moveroute_moving_command = false
      @setdir = true
      @animate = true
      update
    end

    def dispose
      @sprite.dispose
      @sprite = nil
    end

    def move_down
      @y_travelled = 0
      @y_destination = 32
      @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
    end

    def move_left
      @x_travelled = 0
      @x_destination = -32
      @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
    end

    def move_right
      @x_travelled = 0
      @x_destination = 32
      @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
    end

    def move_up
      @y_travelled = 0
      @y_destination = -32
      @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
    end

    # Updates all the necessary variables and sprite properties to stay up-to-date with the event object's state.
    def update
      old_animate_count = @animate_count
      # Refreshes if the current page changed
      if @oldpage != @game_event.current_page
        page = @game_event.current_page
        if page
          graphic = page.graphic
          if graphic.type == :file # Filename with src_rect
            if graphic.param && graphic.param.size > 0
              @sprite.set_bitmap(graphic.param)
              @sprite.src_rect.width = @sprite.bitmap.width / 4
              @sprite.src_rect.height = @sprite.bitmap.height / 4
              @sprite.src_rect.y = (graphic.direction / 2 - 1) * @sprite.src_rect.height
            else
              @sprite.bitmap = nil
            end
            @setdir = true
            @animate = true
          elsif graphic.type == :file_norect # Filename without src_rect
            @sprite.set_bitmap(graphic.param)
            @setdir = false
            @animate = false
          elsif graphic.type == :tile # Tile
            tileset_id, tile_id = graphic.param
            tileset = MKD::Tileset.fetch(tileset_id)
            @sprite.set_bitmap("gfx/tilesets/#{tileset.graphic_name}")
            @sprite.src_rect.width = 32
            @sprite.src_rect.height = 32
            tile_id = graphic.param[1]
            @sprite.src_rect.x = (tile_id % 8) * 32
            @sprite.src_rect.y = (tile_id / 8).floor * 32
            @setdir = false
            @animate = false
          end
        else
          @sprite.bitmap = nil
          @setdir = false
          @animate = false
          @relative_x = @game_event.x * 32 + 16
          @relative_y = @game_event.y * 32 + 32
        end
        @sprite.ox = @sprite.src_rect.width / 2
        @sprite.oy = @sprite.src_rect.height
      end
      # Refreshes if the direction changed
      if @olddirection != @game_event.direction && @setdir
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
      end
      # Queues movement commands
      if @moveroute_wait > 0
        @moveroute_wait -= 1
        next_move if @moveroute_wait == 0
      end
      if @moveroute_ready
        move = @game_event.moveroute[0]
        if move
          @moveroute_ready = false
          name = move
          name = move[0] if move.is_a?(Array)
          execute_move_command(name)
        end
      end
      # Executes horizontal movement
      if @x_travelled && @x_destination && @x_travelled.abs < @x_destination.abs
        # Floating point precision movement
        pixels = @game_event.speed * (@x_destination <=> 0)
        old_x_travelled = @x_travelled
        @x_travelled += pixels
        @animate_count += pixels.abs
        @relative_x += pixels
        if @x_travelled.abs >= @x_destination.abs
          # Account for overshooting the tile, due to rounding errors
          @relative_x += @x_destination - @x_travelled
          @x_travelled = nil
          @x_destination = nil
          next_move
        end
      end
      # Executes vertical movement
      if @y_travelled && @y_destination && @y_travelled.abs < @y_destination.abs
        # Floating point precision movement
        pixels = @game_event.speed * (@y_destination <=> 0)
        old_x_travelled = @y_travelled
        @y_travelled += pixels
        @animate_count += pixels.abs
        @relative_y += pixels
        if @y_travelled.abs >= @y_destination.abs
          # Account for overshooting the tile, due to rounding errors
          @relative_y += @y_destination - @y_travelled
          @y_travelled = nil
          @y_destination = nil
          next_move
        end
      end
      # Animates the sprite.
      if @game_event.current_page && @game_event.current_page.graphic &&
         (@game_event.speed > @game_event.current_page.graphic.frame_update_interval ||
          old_animate_count % @game_event.current_page.graphic.frame_update_interval > @animate_count % @game_event.current_page.graphic.frame_update_interval)
        next_frame
      end
      # Sets the sprite's on-screen location based on the map's offset and the coordinates of the sprite relative to the map.
      map = $visuals.maps[@game_event.map_id]
      @sprite.x = map.real_x + @relative_x
      @sprite.y = map.real_y + @relative_y
      @sprite.z = @sprite.y + 31
      @oldpage = @game_event.current_page
      @olddirection = @game_event.direction
    end

    def next_frame
      return if @sprite.bitmap.nil?
      @sprite.src_rect.x += @sprite.src_rect.width
      @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
    end

    def finish_movement
      next_frame if (@sprite.src_rect.x.to_f / @sprite.bitmap.width * 4) % 2 == 1
    end

    # Executes a move command.
    # @param command [Symbol, Array<Symbol>] the move command to execute.
    def execute_move_command(command)
      validate command => [Symbol, Array]
      command, args = command if command.is_a?(Array)
      case command
      when :down
        @game_event.move_down
      when :left
        @game_event.move_left
      when :right
        @game_event.move_right
      when :up
        @game_event.move_up
      when :turn_down
        @game_event.direction = 2
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        next_move
      when :turn_left
        @game_event.direction = 4
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        next_move
      when :turn_right
        @game_event.direction = 6
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        next_move
      when :turn_up
        @game_event.direction = 8
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        next_move
      when :turn_to_player
        @game_event.turn_to_player
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        next_move
      when :wait
        finish_movement
        @moveroute_wait = args[:frames]
      else
        raise "Invalid move route command #{command.inspect}"
      end
      @moveroute_moving_command = [:down, :left, :right, :up].include?(command)
    end

    private def next_move
      @moveroute_ready = true
      @game_event.moveroute_next(@isauto)
      @isauto = false if @isauto # Disable autonomous move route flag
    end

    # @return [Boolean] whether the event is actually moving.
    def moving?
      return @moveroute_moving_command if !@moveroute_ready
      return !@x_travelled.nil? || !@x_destination.nil? || !@y_travelled.nil? || !@y_destination.nil?
    end

    # Performs a move command from an Autonomous Move Route
    # @param command [Symbol, Array] the move command to execute.
    def automoveroute(command)
      @moveroute_ready = false
      @isauto = true
      execute_move_command(command)
    end
  end
end
