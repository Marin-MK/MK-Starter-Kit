class Visuals
  class Map
    def self.create(game_map)
      $visuals.maps[game_map.id] = self.new(game_map)
    end

    def initialize(game_map)
      tileset = MKD::Tileset.fetch(game_map.data.tileset_id)
      @layers = []
      tilesetbmp = Bitmap.new("gfx/tilesets/" + tileset.graphic_name)
      for i in 0...game_map.data.tiles.size
        if @layers[i].nil?
          @layers[i] = Sprite.new($visuals.viewport)
          @layers[i].bitmap = Bitmap.new(game_map.data.width * 32, game_map.data.height * 32)
        end
        for y in 0...game_map.data.height
          for x in 0...game_map.data.width
            tile_id = game_map.data.tiles[i][x + y * game_map.data.height]
            @layers[i].bitmap.blt(x * 32, y * 32, tilesetbmp, Rect.new((tile_id % 8) * 32, (tile_id / 8).floor * 32, 32, 32))
          end
        end
      end
    end
  end
end