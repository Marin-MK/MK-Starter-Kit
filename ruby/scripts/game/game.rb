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
  end

  def load_map(id)
    if @maps[id]
      raise "Map ##{id} is already loaded!"
    end
    @maps[id] = Game::Map.new(id)
    log(:SYSTEM, "Loaded map ##{id}")
  end

  def is_map_loaded?(id)
    return !@maps[id].nil?
  end

  def unload_map(id)
    if @maps[id].nil?
      raise "Map #{id} cannot be unloaded as it was never loaded to begin with!"
    end
    @maps[id].unload
    log(:SYSTEM, "Unloaded map ##{id}")
  end

  # Takes coordinates relative to map A, and returns the corresponding map and coordinates.
  def get_map_from_connection(mainmap, mapx, mapy)
    if mapx >= 0 && mapy >= 0 && mapx < mainmap.width && mapy < mainmap.height
      return [mainmap.id, mapx, mapy]
    end
    for c in mainmap.connections
      map = MKD::Map.fetch(c.map_id)
      width, height = map.width, map.height
      if mapx >= c.relative_x && mapy >= c.relative_y && mapx < c.relative_x + width && mapy < c.relative_y + height
        return [c.map_id, (c.relative_x - mapx).abs, (c.relative_y - mapy).abs]
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

  def self.get_save_data
    # TO-DO: Not save $game.maps, but only changes in events/maps in an array.
    return {
      game: $game,
      trainer: $trainer
    }
  end

  def self.get_save_folder
    base_path = Dir.home
    if OS.windows?
      base_path = ENV['APPDATA'] if File.writable?(ENV['APPDATA'])
    end
    base_path = "." if !File.writable?(base_path)
    return base_path.gsub(/\\\\/, "/") + "/.mkgames/" + GAME_NAME
  end

  def self.save_exists?
    return File.file?(Game.get_save_folder + "/save.mkd")
  end

  def self.save_game
    folder = Game.get_save_folder
    FileUtils.mkdir_p(folder) if !Dir.exists?(folder)
    filename = folder + "/save.mkd"
    if File.file?(filename)
      FileUtils.copy(filename, filename + ".bak")
    end
    begin
      FileUtils.save_binary_data(filename, Game.get_save_data, :save)
      File.delete(filename + ".bak") if File.file?(filename + ".bak")
      return true
    rescue
      FileUtils.move(filename + ".bak", filename) if File.file?(filename + ".bak")
      return false
    end
  end

  def self.load_game
    if !Game.save_exists?
      raise "No save file could be found."
    else
      filename = Game.get_save_folder + "/save.mkd"
      data = FileUtils.load_binary_data(filename, :save)
      $trainer = data[:trainer]
      $game = data[:game]
      # Set up game data
      raise "Game.load_game not implemented yet"
    end
  end
end
