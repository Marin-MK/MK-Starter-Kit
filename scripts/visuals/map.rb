class Visuals
  class Map
    def self.create(game_map)
      $visuals.maps[game_map.id] = self.new(game_map)
    end

    attr_reader :real_x
    attr_reader :real_y

    def real_x=(value)
      @layers.each { |e| e.x = value }
      @real_x = value
    end

    def real_y=(value)
      @layers.each { |e| e.y = value }
      @real_y = value
    end

    def initialize(game_map)
      @game_map = game_map
      @real_x = Graphics.width / 2 - 16
      @real_y = Graphics.height / 2 - 16
      create_layers
    end

    def create_layers
      tileset = MKD::Tileset.fetch(@game_map.data.tileset_id)
      @layers = []
      tilesetbmp = Bitmap.new("gfx/tilesets/" + tileset.graphic_name)
      for i in 0...@game_map.data.tiles.size
        if @layers[i].nil?
          @layers[i] = Sprite.new($visuals.viewport)
          @layers[i].x = @real_x
          @layers[i].y = @real_y
          @layers[i].z = 10 + 2 * i
          @layers[i].bitmap = Bitmap.new(@game_map.data.width * 32, @game_map.data.height * 32)
        end
        for y in 0...@game_map.data.height
          for x in 0...@game_map.data.width
            tile_id = @game_map.data.tiles[i][x + y * @game_map.data.height]
            next unless tile_id
            @layers[i].bitmap.blt(x * 32, y * 32, tilesetbmp, Rect.new((tile_id % 8) * 32, (tile_id / 8).floor * 32, 32, 32))
          end
        end
      end
    end

    def update
    end
  end
end