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
      @relative_x = (@game_event.x + @game_event.width - 1) * 32 + 16
      @relative_y = (@game_event.y + @game_event.height - 1) * 32 + 32
      @animate = true
      update
    end

    def next_move
      @moveroute_ready = true
      @game_event.moveroute_next(@is_auto)
      @is_auto = false if @is_auto # Disable autonomous move route flag
    end

    def next_frame
      super if @animate
    end

    # Performs a move command from an Autonomous Move Route
    # @param command [Symbol, Array] the move command to execute.
    def automoveroute(command)
      @moveroute_ready = false
      @isauto = true
      execute_move_command(command)
    end

    def update_graphic
      if page = @game_event.current_page
        graphic = page.graphic
        if graphic.type == :file # Filename with src_rect
          if graphic.param && graphic.param.size > 0
            @sprite.set_bitmap(graphic.param)
            @sprite.src_rect.width = @sprite.bitmap.width / graphic.num_frames
            @sprite.src_rect.height = @sprite.bitmap.height / graphic.num_directions
            dir = 0
            dir = graphic.direction / 2 - 1 if graphic.num_directions == 4
            dir = graphic.direction - 1 if graphic.num_directions == 8
            @sprite.src_rect.y = dir * @sprite.src_rect.height
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
        @relative_x = (@game_event.x + @game_event.width - 1) * 32 + 16
        @relative_y = (@game_event.y + @game_event.height - 1) * 32 + 32
      end
      @sprite.ox = @sprite.src_rect.width / 2
      @sprite.oy = @sprite.src_rect.height
    end

    def should_update_graphic
      ret = @oldpage != @game_event.current_page
      @oldpage = @game_event.current_page
      return ret
    end
  end
end
