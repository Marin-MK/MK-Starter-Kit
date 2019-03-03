class Game
  # @return [Game::Player] the player object.
  attr_accessor :player
  # @return [Game::Switches] the global game switches.
  attr_accessor :switches
  # @return [Game::Variables] the global game variables.
  attr_accessor :variables
  # @return [Hash<Integer, Game::Map>] the global collection of game maps.
  attr_accessor :maps

  # Creates a new Game object.
  def initialize
    @maps = {}
  end

  # @return [Game::Map] the map the player is currently on.
  def map
    return @maps[$game.player.map_id]
  rescue
    msgbox caller
    abort
  end

  def load_map(id)
    # Dispose all game maps/visual maps (might need to add here later)
    # Haven't implemented Game::Map#dispose yet
    @maps.values.each { |e| e.dispose if e.respond_to?(:dispose) }
    @maps = {}
    c = MKD::MapConnections.fetch(id)
    if c
      idx = c[0]
      maps = MKD::MapConnections.fetch.maps[idx]
      maps.keys.each do |x,y|
        id = maps[[x, y]]
        @maps[id] = Game::Map.new(id, x, y)
      end
      x, y = self.map.connection[1], self.map.connection[2]
      diffx = @player.x - x
      diffy = @player.y - y
      @maps.values.each do |m|
        map = $visuals.maps[m.id]
        map.real_x += diffx * 32
        map.real_y += diffy * 32
      end
    else
      @maps[id] = Game::Map.new(id)
    end
  end

  def get_map_from_connection(map, mapx, mapy)
    if mapx >= 0 && mapy >= 0 && mapx < map.width && mapy < map.height
      return [map.id, mapx, mapy]
    end
    mx, my = map.connection[1], map.connection[2]
    gx, gy = mx + mapx, my + mapy
    if gx >= 0 && gy >= 0
      maps = MKD::MapConnections.fetch.maps[map.connection[0]]
      maps.keys.each do |x,y|
        mid = maps[[x, y]]
        next if mid == $game.map.id
        map = MKD::Map.fetch(mid)
        width, height = map.width, map.height
        if gx >= x && gy >= y && gx < x + width && gy < y + height
          mapx = gx - x
          mapy = gy - y
          return [mid, mapx, mapy]
        end
      end
    end
    return nil
  end

  # @return [Boolean] whether there are any active events on any map.
  def any_events_running?
    return @maps.values.any? { |m| m.event_running? }
  end

  # Updates the maps and player.
  def update
    @maps.values.each(&:update)
    @player.update
    
  end
end
