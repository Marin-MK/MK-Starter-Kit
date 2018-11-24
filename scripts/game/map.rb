class Game
  class Map
    attr_accessor :id
    attr_accessor :data
    attr_accessor :width
    attr_accessor :height
    attr_accessor :events
    attr_accessor :event_interpreters
    attr_accessor :wait_count

    def initialize(id = 0)
      @id = id
      @data = MKD::Map.fetch(id)
      @width = @data.width
      @height = @data.height
      @tiles = @data.tiles
      @passabilities = @data.passabilities
      # Fetch passability data from the tileset
      @tileset_passabilities = MKD::Tileset.fetch(@data.tileset_id).passabilities
      @events = {}
      Visuals::Map.create(self)
      @data.events.keys.each { |id| @events[id] = Game::Event.new(@id, id, @data.events[id]) }
      @old_event_interpreters = []
      @event_interpreters = []
      @wait_count = 0
    end

    def passable?(x, y, direction = nil)
      return false if x < 0 || x >= @width || y < 0 || y >= @height
      validate x => Fixnum, y => Fixnum, direction => [Fixnum, Symbol, NilClass]
      direction = validate_direction(direction)
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
        tile_id = @tiles[layer][x + y * @height]
        next unless tile_id
        val = @tileset_passabilities[tile_id % 8 + (tile_id / 8).floor * 8]
        return false if val == 0
        next unless direction
        dirbit = [1, 2, 4, 8][(direction / 2) - 1]
        return false if (val & dirbit) != dirbit
      end
      return true
    end

    def update
      @events.values.each(&:update)
      @wait_count -= 1 if @wait_count > 0
      if @event_interpreters.size > 0
        @event_interpreters[0].update
        if @event_interpreters[0].done?
          @event_interpreters.delete_at(0)
        end
      end
    end

    def tile_interaction(x, y)
      return if x < 0 || x >= @width || y < 0 || y >= @height
      if e = @events.values.find { |e| e.x == x && e.y == y && e.current_page && e.current_page.trigger_mode == 0 }
        e.trigger
      end
    end

    def check_event_triggers
      # Line of Sight triggers
      events = @events.values.select { |e| e.current_page && e.current_page.trigger_mode == 1 }
      events.select! do |e|
        dir = e.direction
        maxdiff = e.current_page.trigger_param
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
      events.each(&:trigger)
    end
  end
end