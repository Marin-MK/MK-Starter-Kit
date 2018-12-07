class Visuals
  # The visual component of Game::Map objects.
  class Map
    # Creates a new map linked to the map object.
    # @param game_map [Game::Map] the map object.
    def self.create(game_map)
      $visuals.maps[game_map.id] = self.new(game_map)
    end

    attr_accessor :events
    attr_reader :real_x
    attr_reader :real_y

    def real_x=(value)
      @layers.each { |e| e.x = value }
      @real_x = value
      @events.values.each { |e| e.sprite.x = @real_x + e.relative_x }
    end

    def real_y=(value)
      @layers.each { |e| e.y = value }
      @real_y = value
      @events.values.each { |e| e.sprite.y = @real_y + e.relative_y }
    end

    # Creates a sprite for the map object.
    def initialize(game_map)
      @game_map = game_map
      @real_x = Graphics.width / 2 - 16
      @real_y = Graphics.height / 2 - 16
      @events = {}
      create_layers
    end

    # Subject to change!
    #temp
    def create_layers
      tilesets = {}
      @game_map.data.tilesets.each do |tileset_id|
        tilesets[tileset_id] = MKD::Tileset.fetch(tileset_id)
      end
      tileset_bitmaps = {}
      @game_map.data.tilesets.each do |tileset_id|
        tileset_bitmaps[tileset_id] = Bitmap.new("gfx/tilesets/" + tilesets[tileset_id].graphic_name)
      end
      @layers = []

      for i in 0...@game_map.data.tiles.size
        for y in 0...@game_map.data.height
          for x in 0...@game_map.data.width
            tile_type, tile_id = @game_map.data.tiles[i][x + y * @game_map.data.height]
            next if tile_type.nil?
            tileset_id = @game_map.data.tilesets[tile_type]
            pty = tilesets[tileset_id].priorities[tile_id] || 0
            if @layers[pty].nil?
              @layers[pty] = Sprite.new($visuals.viewport)
              @layers[pty].x = @real_x
              @layers[pty].y = @real_y
              @layers[pty].z = 10 + pty * 3
              @layers[pty].bitmap = Bitmap.new(@game_map.data.width * 32, @game_map.data.height * 32)
            end
            @layers[pty].bitmap.blt(x * 32, y * 32, tileset_bitmaps[tileset_id],
                Rect.new((tile_id % 8) * 32, (tile_id / 8).floor * 32, 32, 32))
          end
        end
      end
    end

    # Updates all this map's events.
    def update
      @events.values.each { |e| e.update }
    end
  end
end