class Game
  # The logical component of map objects.
  class Map
    # @return [Fixnum] the ID of this map.
    attr_accessor :id
    # @return [MKD::Map] the unchangeable data of the map.
    #attr_accessor :data
    # @return [Fixnum] the width of the map in tiles.
    attr_accessor :width
    # @return [Fixnum] the height of the map in tiles.
    attr_accessor :height
    # @return [Hash<Game::Event>] the hash of events on this map stored by ID.
    attr_accessor :events
    # @return [Array<Interpreter>] list of active event interpreters.
    attr_accessor :event_interpreters
    # @return [Array<Interpreter>] list of active event interpreters for parallel processes.
    attr_accessor :parallel_interpreters
    # @return [Fixnum] how long to wait before updating the active event interpreters again.
    attr_accessor :wait_count
    # @return [Array<Fixnum>] map connection data (idx, x, y).
    attr_accessor :connection

    # Creates a new Map object.
    def initialize(id = 0, x = 0, y = 0)
      @id = id
      @x = x
      @y = y
      @width = data.width
      @height = data.height
      @passabilities = data.passabilities
      @tiles = data.tiles
      @tilesets = data.tilesets
      @connection = MKD::MapConnections.fetch(id)
      # Fetch passability data from the tileset
      @tileset_passabilities = {}
      @tilesets.each { |id| @tileset_passabilities[id] = MKD::Tileset.fetch(id).passabilities }
      @events = {}
      Visuals::Map.create(self, x, y)
      data.events.keys.each { |id| @events[id] = Game::Event.new(@id, id, data.events[id]) }
      @event_interpreters = []
      @parallel_interpreters = []
      @wait_count = 0
    end

    def data
      return MKD::Map.fetch(@id)
    end

    # Tests if the specified tile is passable.
    # @param x [Fixnum] the x position to test.
    # @param y [Fixnum] the y position to test.
    # @param direction [Fixnum, Symbol, NilClass] the direction at which the event would step on the tile.
    # @param checking_event [Game::Event, NilClass] the event object that is performing the test.
    # @return [Boolean] whether the tile is passable.
    def passable?(x, y, direction = nil, checking_event = nil)
      validate x => Fixnum, y => Fixnum
      if x < 0 || x >= @width || y < 0 || y >= @height
        if @connection
          map_id, mapx, mapy = $game.get_map_from_connection(self, x, y)
          if map_id
            return $game.maps[map_id].passable?(mapx, mapy, direction, checking_event)
          end
        end
        return false
      end
      validate direction => [Fixnum, Symbol, NilClass]
      direction = validate_direction(direction)

      return false if checking_event != $game.player && x == $game.player.x && y == $game.player.y
      event = @events.values.find { |e| e.x == x && e.y == y }
      return false if event && event.current_page && !event.settings.passable
      unless @passabilities[x + y * @height].nil?
        val = @passabilities[x + y * @height]
        return false if val == 0
        return true if val == 15 || !direction
        dirbit = [1, 2, 4, 8][(direction / 2) - 1]
        return (val & dirbit) == dirbit
      end
      for layer in 0...@tiles.size
        tile_type, tile_id = @tiles[layer][x + y * @height]
        next if tile_type.nil?
        tileset_id = @tilesets[tile_type]
        val = @tileset_passabilities[tileset_id][tile_id % 8 + (tile_id / 8).floor * 8]
        return false if val == 0
        next unless direction
        dirbit = [1, 2, 4, 8][(direction / 2) - 1]
        return false if (val & dirbit) != dirbit
      end
      return true
    end

    # Updates this map's events and interpreters.
    def update
      @events.values.each(&:update)
      @wait_count -= 1 if @wait_count > 0
      if @event_interpreters.size > 0
        if @event_interpreters[0].done?
          @event_interpreters.delete_at(0)
        else
          @event_interpreters[0].update
        end
      end
      @parallel_interpreters.each do |i|
        i.restart if i.done?
        i.update
      end
    end

    # Called when the player presses A on a tile. Triggers events if conditions are met.
    # @param x [Fixnum] the x position of the tile to interact with.
    # @param y [Fixnum] the y position of the tile to interact with.
    def tile_interaction(x, y)
      validate x => Fixnum, y => Fixnum
      return if x < 0 || x >= @width || y < 0 || y >= @height
      if e = @events.values.find { |e| e.x == x && e.y == y && e.current_page && e.current_page.has_trigger?(:action) }
        e.trigger(:action)
      end
    end

    # Tests event triggers that happen with ranges or lines of sight.
    # @param new_step [Boolean] whether the player has just moved.
    def check_event_triggers(new_step = false)
      return if $game.map != self
      # Line of Sight triggers
      events = @events.values.select { |e| e.current_page && e.current_page.has_trigger?(:line_of_sight) }
      events.select! do |e|
        dir = e.direction
        maxdiff = e.current_page.trigger_argument(:line_of_sight, :tiles)
        if dir == 2 && e.x == $game.player.x
          diff = $game.player.y - e.y
          next diff > 0 && diff <= maxdiff
        elsif dir == 4 && e.y == $game.player.y
          diff = e.x - $game.player.x
          next diff > 0 && diff <= maxdiff
        elsif dir == 6 && e.y == $game.player.y
          diff = $game.player.x - e.x
          next diff > 0 && diff <= maxdiff
        elsif dir == 8 && e.x == $game.player.x
          diff = e.y - $game.player.y
          next diff > 0 && diff <= maxdiff
        end
      end
      events.each { |e| e.trigger(:line_of_sight) }

      # On Tile triggers
      events = @events.values.select { |e| e.current_page && e.current_page.has_trigger?(:on_tile) }
      events.select! do |e|
        tiles = e.current_page.trigger_argument(:on_tile, :tiles)
        on_trigger_tile = tiles.any? { |e| e[0] == $game.player.x && e[1] == $game.player.y }
        next on_trigger_tile
      end
      events.each { |e| e.trigger(:on_tile) }

      # If the check happens just after moving. This would trigger Player Touch events,
      # where the player touches an event.
      if new_step
        newx, newy = facing_coordinates($game.player.x, $game.player.y, $game.player.direction)
        events = @events.values.select do |e|
          e.current_page && e.current_page.has_trigger?(:player_touch) &&
          e.x == newx &&
          e.y == newy
        end
        events.each { |e| e.trigger(:player_touch) }
      end
    end
  end
end
