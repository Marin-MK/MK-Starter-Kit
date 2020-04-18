class Visuals
  # The visual component of Game::Event objects.
  class Event < BaseCharacter
    # Creates a new sprite linked to the event object.
    # @param game_event [Game::Event] the event object.
    def self.create(game_event)
      $visuals.maps[game_event.map_id].events[game_event.id] = self.new(game_event)
    end

    # @return [Integer] the x position of this event relative to the map.
    attr_accessor :relative_x
    # @return [Integer] the y position of this event relative to the map.
    attr_accessor :relative_y

    # Creates a new sprite for the event object.
    def initialize(game_event)
      super(game_event)
      @game_event = game_event
      @relative_x = @game_event.x * 32 + 16
      @relative_y = @game_event.y * 32 + 32
      @animate = true
      update
    end

    # Updates all the necessary variables and sprite properties to stay up-to-date with the event object's state.
    def update
      super
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
      # Sets the sprite's on-screen location based on the map's offset and the coordinates of the sprite relative to the map.
      map = $visuals.maps[@game_event.map_id]
      @sprite.x = (map.real_x + @relative_x).round
      @sprite.y = (map.real_y + @relative_y).round
      @oldpage = @game_event.current_page
      @olddirection = @game_event.direction
    end

    def next_move
      @moveroute_ready = true
      @game_event.moveroute_next(@is_auto)
      @is_auto = false if @is_auto # Disable autonomous move route flag
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
