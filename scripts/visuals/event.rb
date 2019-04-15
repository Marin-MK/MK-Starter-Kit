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
      @xdist = []
      @xtrav = []
      @xstart = []
      @ydist = []
      @ytrav = []
      @ystart = []
      @anim = []
      @relative_x = @game_event.x * 32 + 16
      @relative_y = @game_event.y * 32 + 32
      @moveroute_wait = 0
      @moveroute_moving_command = false
      @setdir = true
      @animate = true
      update
    end

    # Updates all the necessary variables and sprite properties to stay up-to-date with the event object's state.
    def update
      oldbmp = @sprite.bitmap
      if @oldpage != @game_event.current_page
        page = @game_event.current_page
        if page
          graphic = page.graphic
          if graphic[:type] == :file # Filename with src_rect
            if graphic[:param] && graphic[:param].size > 0
              @sprite.set_bitmap(graphic[:param])
              @sprite.src_rect.width = @sprite.bitmap.width / 4
              @sprite.src_rect.height = @sprite.bitmap.height / 4
              @sprite.src_rect.y = (graphic[:direction] / 2 - 1) * @sprite.src_rect.height
            else
              @sprite.bitmap = nil
            end
            @setdir = true
            @animate = true
          elsif graphic[:type] == :file_norect # Filename without src_rect
            @sprite.set_bitmap(graphic[:param])
            @setdir = false
            @animate = false
          elsif graphic[:type] == :tile # Tile
            tileset_id, tile_id = graphic[:param]
            tileset = MKD::Tileset.fetch(tileset_id)
            @sprite.set_bitmap("gfx/tilesets/#{tileset.graphic_name}")
            @sprite.src_rect.width = 32
            @sprite.src_rect.height = 32
            tile_id = graphic[:param][1]
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

      if oldbmp != @sprite.bitmap && @sprite.bitmap.nil?
        @xdist = []
        @xtrav = []
        @xstart = []
        @ydist = []
        @ytrav = []
        @ystart = []
        @anim = []
        @moveroute_wait = 0
        @moveroute_ready = true
      end

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

      # Executes the horizontal movement
      if @xdist[0] && @xtrav[0] && @xstart[0]
        if @xtrav[0].abs < @xdist[0].abs
          dist = @game_event.speed * (@xdist[0] < 0 ? -1 : 1)
          @xtrav[0] += dist
          @xtrav[0] = @xdist[0] < 0 ? [@xtrav[0], @xdist[0]].max : [@xtrav[0], @xdist[0]].min
          @relative_x = @xstart[0] + @xtrav[0]
          if @anim[0].size > 0 && (@xdist[0] > 0 && @xtrav[0] > @anim[0][0] || @xdist[0] < 0 && @xtrav[0] < @anim[0][0])
            if @animate
              @sprite.src_rect.x += @sprite.src_rect.width
              @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
            end
            @anim[0].delete_at(0)
          end
        else
          @xtrav.delete_at(0)
          @xdist.delete_at(0)
          @xstart.delete_at(0)
          @anim.delete_at(0)
          next_move
        end
      end
      # Executes the vertical movement
      if @ydist[0] && @ytrav[0] && @ystart[0]
        if @ytrav[0].abs < @ydist[0].abs
          dist = @game_event.speed * (@ydist[0] < 0 ? -1 : 1)
          @ytrav[0] += dist
          @ytrav[0] = @ydist[0] < 0 ? [@ytrav[0], @ydist[0]].max : [@ytrav[0], @ydist[0]].min
          @relative_y = @ystart[0] + @ytrav[0]
          if @anim[0].size > 0 && (@ydist[0] > 0 && @ytrav[0] > @anim[0][0] || @ydist[0] < 0 && @ytrav[0] < @anim[0][0])
            if @animate
              @sprite.src_rect.x += @sprite.src_rect.width
              @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
            end
            @anim[0].delete_at(0)
          end
        else
          @ytrav.delete_at(0)
          @ydist.delete_at(0)
          @ystart.delete_at(0)
          @anim.delete_at(0)
          next_move
        end
      end

      # Sets the sprite's on-screen location based on the map's offset and the coordinates of the sprite relative to the map.
      map = $visuals.maps[@game_event.map_id]
      @sprite.x = map.real_x + @relative_x
      @sprite.y = map.real_y + @relative_y
      @sprite.z = @sprite.y + 31

      @oldpage = @game_event.current_page
      @olddirection = @game_event.direction
    end

    # Executes a move command.
    # @param command [Symbol, Array<Symbol>] the move command to execute.
    def execute_move_command(command)
      validate command => [Symbol, Array]
      command, args = command if command.is_a?(Array)
      case command
      when :down
        @ydist << 32
        @ytrav << 0
        @ystart << (@ystart[0] ? @ystart.last + @ydist.last : @relative_y)
        @anim << [0, 16]
        @game_event.direction = 2
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        @game_event.y += 1
      when :left
        @xdist << -32
        @xtrav << 0
        @xstart << (@xstart[0] ? @xstart.last + @xdist.last : @relative_x)
        @anim << [0, -16]
        @game_event.direction = 4
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        @game_event.x -= 1
      when :right
        @xdist << 32
        @xtrav << 0
        @xstart << (@xstart[0] ? @xstart.last + @xdist.last : @relative_x)
        @anim << [0, 16]
        @game_event.direction = 6
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        @game_event.x += 1
      when :up
        @ydist << -32
        @ytrav << 0
        @ystart << (@ystart[0] ? @ystart.last + @ydist.last : @relative_y)
        @anim << [0, -16]
        @game_event.direction = 8
        @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height if @setdir
        @game_event.y -= 1
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
      return false
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
