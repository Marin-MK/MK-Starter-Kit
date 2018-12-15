class Visuals
  # The visual component of Game::Map objects.
  class Map
    # Creates a new map linked to the map object.
    # @param game_map [Game::Map] the map object.
    def self.create(game_map, real_x = 0, real_y = 0)
      $visuals.maps[game_map.id] = self.new(game_map, real_x, real_y)
    end

    # @return [Hash<Visuals::Event>] the hash of event visuals.
    attr_accessor :events
    # @return [Fixnum] the x position of the top-left corner of the map.
    attr_reader :real_x
    # @return [Fixnum] the y position of the top-left corner of the map.
    attr_reader :real_y

    def real_x=(value)
      #diff = @real_x - value
      #$visuals.map_renderer.each { |e| e.real_x -= diff }
      @real_x = value
      #$visuals.map_renderer.refresh_tiles
      @events.values.each { |e| e.sprite.x = @real_x + e.relative_x }
    end

    def real_y=(value)
      #diff = @real_y - value
      #$visuals.map_renderer.each { |e| e.real_y -= diff }
      @real_y = value
      #$visuals.map_renderer.refresh_tiles
      @events.values.each { |e| e.sprite.y = @real_y + e.relative_y }
    end

    # Creates a new Map object.
    def initialize(game_map, x = 0, y = 0)
      @game_map = game_map
      @real_x = Graphics.width / 2 - 16 + 32 * x
      @real_y = Graphics.height / 2 - 16 + 32 * y
      @events = {}
    end

    # Updates all this map's events.
    def update
      @events.values.each { |e| e.update }
    end
  end
end
