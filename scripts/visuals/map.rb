class Visuals
  # The visual component of Game::Map objects.
  class Map
    # Creates a new map linked to the map object.
    # @param game_map [Game::Map] the map object.
    def self.create(game_map)
      $visuals.maps[game_map.id] = self.new(game_map)
    end

    # @return [Hash<Visuals::Event>] the hash of event visuals.
    attr_accessor :events
    # @return [Fixnum] the x position of the top-left corner of the map.
    attr_reader :real_x
    # @return [Fixnum] the y position of the top-left corner of the map.
    attr_reader :real_y

    def real_x=(value)
      diff = @real_x - value
      $visuals.tiles.each { |e| e.real_x -= diff }
      @real_x = value
      refresh_tiles
      @events.values.each { |e| e.sprite.x = @real_x + e.relative_x }
    end

    def real_y=(value)
      diff = @real_y - value
      $visuals.tiles.each { |e| e.real_y -= diff }
      @real_y = value
      refresh_tiles
      @events.values.each { |e| e.sprite.y = @real_y + e.relative_y }
    end

    # Creates a new Map object.
    def initialize(game_map)
      @game_map = game_map
      @real_x = Graphics.width / 2 - 16
      @real_y = Graphics.height / 2 - 16
      @events = {}
      refresh_tiles
    end

    # Updates all this map's events.
    def update
      @events.values.each { |e| e.update }
    end

    # Refreshes or creates the tile array of sprites.
    def refresh_tiles
      if $visuals.tiles
        @startx = $visuals.tiles[0].real_x.round / -32 - 2
        @starty = $visuals.tiles[0].real_y.round / -32 - 2
        if @starty > 0
          @starty.times do
            $visuals.tiles.move_up do |sprite|
              sprite.mapy += 14
              sprite.real_y += 32 * 14
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
          $temp_tilesets = nil
          $temp_bitmaps = nil
        elsif @starty < 0
          @starty.abs.times do
            $visuals.tiles.move_down do |sprite|
              sprite.mapy -= 14
              sprite.real_y -= 32 * 14
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
          $temp_tilesets = nil
          $temp_bitmaps = nil
        end
        if @startx > 0
          @startx.times do
            $visuals.tiles.move_left do |sprite|
              sprite.mapx += 19
              sprite.real_x += 32 * 19
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
          $temp_tilesets = nil
          $temp_bitmaps = nil
        elsif @startx < 0
          @startx.abs.times do
            $visuals.tiles.move_right do |sprite|
              sprite.mapx -= 19
              sprite.real_x -= 32 * 19
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
          $temp_tilesets = nil
          $temp_bitmaps = nil
        end
      else
        # Screen fits exactly 15x10 tiles, but it has 2 around them (making it 19x14)
        # so the game has time to refresh without showing a black border during movement.
        tiles = []
        (19 * 14).times { tiles << TileSprite.new($visuals.viewport) }
        $visuals.tiles = TileArray.new(tiles)
        @startx = @real_x / -32 - 2
        @starty = @real_y / -32 - 2
        for y in 0...14
          for x in 0...19
            mapx = @startx + x
            mapy = @starty + y
            idx = x + y * 19
            $visuals.tiles[idx].real_x = @real_x + mapx * 32
            $visuals.tiles[idx].real_y = @real_y + mapy * 32
            draw_tile($visuals.tiles[idx], mapx, mapy)
          end
        end
        $temp_tilesets = nil
        $temp_bitmaps = nil
        # Don't dispose the bitmaps hash because tiles reference these instances; they're not clones.
        @startx = $visuals.tiles[0].real_x / -32 - 2
        @starty = $visuals.tiles[0].real_y / -32 - 2
      end
    end

    # Draws all tiles in a certain position to a sprite.
    # @param sprite [TileSprite] the tile sprite to draw to.
    # @param mapx [Fixnum] the x position of the tile on the map.
    # @param mapy [Fixnum] the y position of the tile on the map.
    def draw_tile(sprite, mapx, mapy)
      $temp_tilesets ||= {}
      $temp_bitmaps ||= {}
      # Reset the sprite to a blank tilesprite
      sprite.clear
      sprite.mapx = mapx
      sprite.mapy = mapy
      # Reconfigure if it's a valid and visible tile
      if mapx >= 0 && mapx < @game_map.width && mapy >= 0 && mapy < @game_map.height
        for layer in 0...@game_map.data.tiles.size
          tile_type, tile_id = @game_map.data.tiles[layer][mapx + @game_map.height * mapy]
          next if tile_type.nil?
          tileset_id = @game_map.data.tilesets[tile_type]
          # Temporary tileset cache
          if $temp_tilesets[tileset_id]
            tileset = $temp_tilesets[tileset_id]
          else
            tileset = $temp_tilesets[tileset_id] = MKD::Tileset.fetch(tileset_id)
          end
          # Temporary bitmap cache
          if $temp_bitmaps[tileset.graphic_name]
            bmp = $temp_bitmaps[tileset.graphic_name]
          else
            bmp = $temp_bitmaps[tileset.graphic_name] = Bitmap.new("gfx/tilesets/" + tileset.graphic_name)
          end
          priority = tileset.priorities[tile_id] || 0
          sprite.set(layer, bmp, tile_id, priority)
        end
      end
    end
  end
end
