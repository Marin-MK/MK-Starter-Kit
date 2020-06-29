class Visuals
  class MapRenderer
    # One sprite for one (x,y) position. Holds multiple sprites for multiple layers.
    class TileSprite
      # You can create 48 unique tile combinations with an autotile.
      # Those tile combinations are created by combining little 16x16 chunks
      # from the original source autotile image according to the list below.
      AutotileCombinations = {
        legacy: [
          [26, 27, 32, 33], [ 4, 27, 32, 33], [26,  5, 32, 33], [ 4,  5, 32, 33],
          [26, 27, 32, 11], [ 4, 27, 32, 11], [26,  5, 32, 11], [ 4,  5, 32, 11],
          [26, 27, 10, 33], [ 4, 27, 10, 33], [26,  5, 10, 33], [ 4,  5, 10, 33],
          [26, 27, 10, 11], [ 4, 27, 10, 11], [26,  5, 10, 11], [ 4,  5, 10, 11],
          [24, 25, 30, 31], [24,  5, 30, 31], [24, 25, 30, 11], [24,  5, 30, 11],
          [14, 15, 20, 21], [14, 15, 20, 11], [14, 15, 10, 21], [14, 15, 10, 11],
          [28, 29, 34, 35], [28, 29, 10, 35], [ 4, 29, 34, 35], [ 4, 29, 10, 35],
          [38, 39, 44, 45], [ 4, 39, 44, 45], [38,  5, 44, 45], [ 4,  5, 44, 45],
          [24, 29, 30, 35], [14, 15, 44, 45], [12, 13, 18, 19], [12, 13, 18, 11],
          [16, 17, 22, 23], [16, 17, 10, 23], [40, 41, 46, 47], [ 4, 41, 46, 47],
          [36, 37, 42, 43], [36,  5, 42, 43], [12, 17, 18, 23], [12, 13, 42, 43],
          [36, 41, 42, 47], [16, 17, 46, 47], [12, 17, 42, 47], [ 0,  1,  6,  7]
        ],
        full_corners: [
          [26, 27, 32, 33], [48, 49, 54, 55], [50, 51, 56, 57], [ 4,  5, 32, 33],
          [62, 63, 68, 69], [ 4, 27, 32, 11], [26,  5, 32, 11], [ 4,  5, 32, 11],
          [60, 61, 66, 67], [ 4, 27, 10, 33], [26,  5, 10, 33], [ 4,  5, 10, 33],
          [26, 27, 10, 11], [ 4, 27, 10, 11], [26,  5, 10, 11], [ 4,  5, 10, 11],
          [24, 25, 30, 31], [24,  5, 30, 31], [24, 25, 30, 11], [24,  5, 30, 11],
          [14, 15, 20, 21], [14, 15, 20, 11], [14, 15, 10, 21], [14, 15, 10, 11],
          [28, 29, 34, 35], [28, 29, 10, 35], [ 4, 29, 34, 35], [ 4, 29, 10, 35],
          [38, 39, 44, 45], [ 4, 39, 44, 45], [38,  5, 44, 45], [ 4,  5, 44, 45],
          [24, 29, 30, 35], [14, 15, 44, 45], [12, 13, 18, 19], [12, 13, 18, 11],
          [16, 17, 22, 23], [16, 17, 10, 23], [40, 41, 46, 47], [ 4, 41, 46, 47],
          [36, 37, 42, 43], [36,  5, 42, 43], [12, 17, 18, 23], [12, 13, 42, 43],
          [36, 41, 42, 47], [16, 17, 46, 47], [12, 17, 42, 47], [ 0,  1,  6,  7]
        ],
        rmvx: [
          [13, 14, 17, 18], [ 2, 14, 17, 18], [13,  3, 17, 18], [ 2,  3, 17, 18],
          [13, 14, 17,  7], [ 2, 14, 17,  7], [13,  3, 17,  7], [ 2,  3, 17,  7],
          [13, 14,  6, 18], [ 2, 14,  6, 18], [13,  3,  6, 18], [ 2,  3,  6, 18],
          [13, 14,  6,  7], [ 2, 14,  6,  7], [13,  3,  6,  7], [ 2,  3,  6,  7],
          [12, 13, 16, 17], [12,  3, 16, 17], [12, 13, 16,  7], [12,  3, 16,  7],
          [ 9, 10, 13, 14], [ 9, 10, 13,  7], [ 9, 10,  6, 14], [ 9, 10,  6,  7],
          [14, 15, 18, 19], [14, 15,  6, 19], [ 2, 15, 18, 19], [ 2, 15,  6, 19],
          [17, 18, 21, 22], [ 2, 18, 21, 22], [17,  3, 21, 22], [ 2,  3, 21, 22],
          [12, 15, 16, 19], [ 9, 10, 21, 22], [ 8,  9, 12, 13], [ 8,  9, 12,  7],
          [10, 11, 14, 15], [10, 11,  6, 15], [18, 19, 22, 23], [ 2, 19, 22, 23],
          [16, 17, 20, 21], [16,  3, 20, 21], [ 8, 11, 12, 15], [ 8,  9, 20, 21],
          [16, 19, 20, 23], [10, 11, 22, 23], [ 8, 11, 20, 23], [ 0,  1,  4,  5]
        ]
      }

      attr_reader :real_x
      attr_reader :real_y
      attr_accessor :mapx
      attr_accessor :mapy
      attr_accessor :sprites

      def initialize(viewport)
        @sprites = {0 => Sprite.new(viewport, {priority: 0, tile_id: 0})}
        @viewport = viewport
        @real_x = 0
        @real_y = 0
        @priority = 0
        @mapx = 0
        @mapy = 0
        @i = 0
      end

      def real_x=(value)
        @real_x = value
        @sprites.each_value { |s| s.x = value if s }
      end

      def real_y=(value)
        @real_y = value
        @sprites.each_value do |s|
          s.y = value if s
          s.z = s.y + s.hash[:priority] * 32 + 32 if s.hash[:priority]
        end
        @sprites.each_value { |s| s.z = s.y + s.hash[:priority] * 32 + 32 if s && s.hash[:priority] && !s.hash[:special] }
      end

      def priority=(value)
        @sprites.each_value { |s| s.z = s.y + s.hash[:priority] * 32 + 32 if s && s.hash[:priority] }
      end

      def clear
        @sprites.each_value do |s|
          if s && !s.hash[:special]
            s.bitmap = nil
            s.hash = {}
            s.z = 0
          end
        end
      end

      def dispose
        @sprites.each_value { |e| e.dispose if e }
        @sprites = {}
      end

      def update(i)
        @i = i
        @sprites.each do |key, sprite|
          if sprite.hash[:autotile]
            map_id, tile_data = sprite.hash[:map_id], sprite.hash[:tile_data]
            tile_type, index, tile_id = tile_data
            autotile_id = MKD::Map.fetch(map_id).autotiles[index]
            autotile = MKD::Autotile.fetch(autotile_id)
            if autotile.animate_speed > 0 && @i % autotile.animate_speed == 0
              draw_autotile(key, map_id, tile_data, (@i / autotile.animate_speed).floor)
            end
          end
        end
      end

      def draw_tile(layer, map_id, tile_data)
        tile_type, index, tile_id = tile_data
        tileset_id = $game.maps[map_id].data.tilesets[index]
        tileset = MKD::Tileset.fetch(tileset_id)
        priority = tileset.priorities[tile_id] || 0
        @sprites[layer].bitmap = tileset.bitmap
        @sprites[layer].src_rect.width = 32
        @sprites[layer].src_rect.height = 32
        @sprites[layer].src_rect.x = tile_id % 8 * 32
        @sprites[layer].src_rect.y = (tile_id / 8).floor * 32
        @sprites[layer].z = @sprites[layer].y + priority * 32 + 32
        @sprites[layer].hash = {priority: priority, map_id: map_id, tile_data: tile_data, autotile: false}
      end

      def draw_autotile(layer, map_id, tile_data, frame = nil)
        tile_type, index, tile_id = tile_data
        autotile_id = MKD::Map.fetch(map_id).autotiles[index]
        autotile = MKD::Autotile.fetch(autotile_id)
        frame = (@i / autotile.animate_speed).floor if frame.nil?
        bmp = autotile.bitmap
        priority = autotile.priorities[tile_id] || 0
        @sprites[layer].bitmap.dispose if @sprites[layer].bitmap
        @sprites[layer].bitmap = Bitmap.new(32, 32)
        if autotile.format == :single
          anim_x = (32 * frame) % bmp.width # 32px * 1 tile per frame = 32px
          @sprites[layer].bitmap.blt(0, 0, bmp, Rect.new(anim_x, 0, 32, 32))
        else
          anim_x = (96 * frame) % bmp.width # 32px * 3 tiles per frame = 96px
          # Fetch the coordinates of the 4 16x16 chunks in the original autotile image
          # with which to create one big 32x32 tile.
          tiles = AutotileCombinations[autotile.format][tile_id]
          for i in 0...4
            @sprites[layer].bitmap.blt(16 * (i % 2), 16 * (i / 2).floor, bmp,
                Rect.new(16 * (tiles[i] % 6) + anim_x, 16 * (tiles[i] / 6).floor, 16, 16))
          end
        end
        @sprites[layer].z = @sprites[layer].y + priority * 32 + 32
        @sprites[layer].hash = {priority: priority, map_id: map_id, tile_data: tile_data, frame: frame, autotile: true}
      end

      def set(layer, map_id, tile_data)
        tile_type, index, tile_id = tile_data
        return if tile_type.nil?

        if !@sprites[layer]
          @sprites[layer] = Sprite.new(@viewport)
          @sprites[layer].x = @real_x
          @sprites[layer].y = @real_y
        end

        if tile_type == 0 # Tileset
          draw_tile(layer, map_id, tile_data)
        elsif tile_type == 1 # Autotile
          draw_autotile(layer, map_id, tile_data)
        else
          raise "Invalid tile type."
        end
      end
    end
  end
end
