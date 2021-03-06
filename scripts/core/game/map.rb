class Game
  # The logical component of map objects.
  class Map
    # @return [Integer] the ID of this map.
    attr_accessor :id
    # @return [Hash<Game::Event>] the hash of events on this map stored by ID.
    attr_accessor :events
    # @return [Array<Interpreter>] list of active event interpreters.
    attr_accessor :event_interpreters
    # @return [Array<Interpreter>] list of active event interpreters for parallel processes.
    attr_accessor :parallel_interpreters
    # @return [Integer] how long to wait before updating the active event interpreters again.
    attr_accessor :wait_count

    # Creates a new Map object.
    def initialize(id = 0, x = 0, y = 0)
      @id = id
      @x = x
      @y = y
      setup_visuals
      @event_interpreters = []
      @parallel_interpreters = []
      @wait_count = 0
    end

    def setup_visuals
      Visuals::Map.create(self, @x, @y)
      if @events && @events.size > 0
        @events.each_value { |e| e.setup_visuals }
      else
        @events = {}
        data.events.each_key { |id| @events[id] = Game::Event.new(@id, id) }
      end
    end

    def data
      return MKD::Map.fetch(@id)
    end

    # @return [Integer] the width of the map in tiles.
    def width
      return data.width
    end

    # @return [Integer] the height of the map in tiles.
    def height
      return data.height
    end

    def tiles
      return data.tiles
    end

    def tilesets
      return data.tilesets
    end

    def autotiles
      return data.autotiles
    end

    def connections
      return data.connections
    end

    def unload
      @events.each { |e| e.unload }
      $visuals.maps[@id].dispose
      $visuals.maps.delete(@id) if $visuals.maps[@id]
      $game.maps.delete(@id) if $game.maps[@id]
    end

    # Tests if the specified tile is passable.
    # @param x [Integer] the x position to test.
    # @param y [Integer] the y position to test.
    # @param direction [Integer, Symbol, NilClass] the direction at which the event would step on the tile.
    # @param checking_event [Game::Event, NilClass] the event object that is performing the test.
    # @return [Boolean] whether the tile is passable.
    def passable?(x, y, direction = nil, checking_character = nil)
      validate \
          x => Integer,
          y => Integer,
          direction => [Integer, Symbol, NilClass],
          checking_character => [Game::BaseCharacter, NilClass]
      map_id = checking_character.map_id
      # If the coordinate goes off the map
      if x < 0 || x >= width || y < 0 || y >= height
        # If an event is checking
        if checking_character.is_a?(Game::Event)
          # Return false - Events can't cross maps
          return false
        elsif checking_character.is_a?(Game::Player) && !connections.empty?
          # Return passability check run by the facing map.
          map_id, mapx, mapy = $game.get_map_from_connection(self, x, y)
          if map_id
            return $game.maps[map_id].passable?(mapx, mapy, direction, checking_character)
          end
        end
        return false
      end
      validate direction => [Integer, Symbol, NilClass]
      direction = validate_direction(direction)
      # Invert direction: if player is facing left, they're coming from the right, etc.
      direction = 10 - direction if direction.is_a?(Integer)

      return false if checking_character != $game.player && x == $game.player.x && y == $game.player.y && map_id == $game.player.map_id
      @events.each_value do |e|
        next if e.current_page.nil? || e.current_page.settings.passable
        return false if x >= e.x && x < e.x + e.width && y >= e.y && y < e.y + e.height
      end
      for layer in 0...tiles.size
        tile_type, index, id = tiles[layer][x + y * width]
        next if tile_type.nil?
        val = 0 # Default to impassable
        if tile_type == 0 # Tileset
          tileset_id = tilesets[index]
          val = MKD::Tileset.fetch(tileset_id).passabilities[id]
        elsif tile_type == 1 # Autotile
          autotile_id = autotiles[index]
          val = MKD::Autotile.fetch(autotile_id).passabilities[id]
        else
          raise "Invalid tile type."
        end
        return false if val == 0
        next unless direction
        dirbit = [1, 2, 4, 8][(direction / 2) - 1]
        return false if (val & dirbit) != dirbit
      end
      return true
    end

    # Updates this map's events and interpreters.
    def update
      @events.each_value(&:update)
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

    # @return [Boolean] whether or not there's currently an event running.
    def event_running?
      return @event_interpreters[0] && !@event_interpreters[0].done?
    end

    def can_move?
      return false if @event_interpreters[0] && !@event_interpreters[0].done? && !@event_interpreters[0].wait_for_move_completion
      return true
    end

    # Called when the player presses A on a tile. Triggers events if conditions are met.
    # @param x [Integer] the x position of the tile to interact with.
    # @param y [Integer] the y position of the tile to interact with.
    def tile_interaction(x, y)
      validate x => Integer, y => Integer
      return if x < 0 || x >= width || y < 0 || y >= height
      event = @events.values.find do |e|
        next x >= e.x && x < e.x + e.width && y >= e.y && y < e.y + e.height && e.current_page &&
             [:action, :player_touch, :event_touch].include?(e.current_page.trigger_mode)
      end
      event.trigger if event
    end

    # Tests event triggers that happen with ranges or lines of sight.
    # @param new_step [Boolean] whether the player has just moved.
    def check_event_triggers(new_step = false)
      return if $game.map != self
      # Line of Sight triggers
      events = @events.values.select do |e|
        next e.current_page && e.current_page.trigger_param.is_a?(Integer) && e.current_page.trigger_param > 0 &&
             (e.current_page.trigger_mode == :event_touch || e.current_page.trigger_mode == :player_touch)
      end
      events.select! do |e|
        dir = e.direction
        maxdiff = e.current_page.trigger_param
        if dir == 2 && $game.player.x >= e.x && $game.player.x < e.x + e.width
          diff = $game.player.y - e.y - e.height + 1
          next diff > 0 && diff <= maxdiff
        elsif dir == 4 && $game.player.y >= e.y && $game.player.y < e.y + e.height
          diff = e.x - $game.player.x
          next diff > 0 && diff <= maxdiff
        elsif dir == 6 && $game.player.y >= e.y && $game.player.y < e.y + e.height
          diff = $game.player.x - e.x - e.width + 1
          next diff > 0 && diff <= maxdiff
        elsif dir == 8 && $game.player.x >= e.x && $game.player.x < e.x + e.width
          diff = e.y - $game.player.y
          next diff > 0 && diff <= maxdiff
        end
      end
      events.each { |e| e.trigger }

      # If the check happens just after moving. This would trigger Player Touch events,
      # where the player touches an event.
      if new_step
        events = @events.values.select do |e|
          next e.current_page && e.current_page.trigger_mode == :player_touch &&
               $game.player.x >= e.x && $game.player.x < e.x + e.width && $game.player.y >= e.y && $game.player.y < e.y + e.height
        end
        events.each { |e| e.trigger }
      end
    end

    def check_terrain_tag
      return if $game.map != self
      tags = []
      for layer in 0...self.tiles.size
        for i in 0...self.tiles[layer].size
          mapx = i % self.width
          mapy = (i / self.height).floor
          if mapx == $game.player.x && mapy == $game.player.y
            tiledata = self.tiles[layer][i]
            next if tiledata.nil?
            tile_type, index, id = tiledata
            if tile_type == 0 # Tileset
              tileset_id = self.tilesets[index]
              tag = MKD::Tileset.fetch(tileset_id).tags[id]
            elsif tile_type == 1 # Autotile
              autotile_id = self.autotiles[index]
              tag = MKD::Autotile.fetch(autotile_id).tags[id]
            else
              raise "Invalid tile type."
            end
            tags << tag unless tag.nil?
          end
        end
      end
      for i in 0...tags.size
        tag = tags[tags.size - 1 - i]
        # Check for tags here
      end
    end
  end
end
