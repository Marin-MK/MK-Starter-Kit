class Visuals
  # Rectangular array that can shift in each direction. Used for the tile sprites in the map renderer.
  # Principle:
  # 1 2 3                      3 1 2
  # 4 5 6  ->  move_right  ->  6 4 5
  # 7 8 9                      9 7 8
  class MapRenderer
    TILECOUNTX = (SCREENWIDTH / 32.0).ceil
    TILECOUNTY = (SCREENHEIGHT / 32.0).ceil
    XBUFFER = 1
    YBUFFER = 1

    XSIZE = TILECOUNTX + XBUFFER * 2
    YSIZE = TILECOUNTY + YBUFFER * 2
    TOTALSIZE = XSIZE * YSIZE

    attr_accessor :array

    def initialize(array = [])
      @array = array
    end

    def [](key)
      return @array[key]
    end

    def []=(key, value)
      @array[key] = value
    end

    def each
      @array.each { |e| yield e }
    end

    def size
      return @array.size
    end

    def empty?
      return @array.empty?
    end

    # Moves the right-most column to the left.
    def move_right
      for i in 0...@array.size
        if (i + 1) % XSIZE == 0
          v = @array.delete_at(i)
          yield v if block_given?
          @array.insert(i - XSIZE + 1, v)
        end
      end
    end

    # Moves the left-most column to the right.
    def move_left
      for i in 0...@array.size
        if i % XSIZE == 0
          v = @array.delete_at(i)
          yield v if block_given?
          @array.insert(i + XSIZE - 1, v)
        end
      end
    end

    def move_x(diff)
      @array.each { |e| e.real_x -= diff }
      $visuals.map_renderer.refresh_tiles
    end

    def move_y(diff)
      @array.each { |e| e.real_y -= diff }
      $visuals.map_renderer.refresh_tiles
    end

    # Moves the top-most row to the bottom.
    def move_up
      @array[0...XSIZE].each_with_index { |e, x| yield e, x } if block_given?
      oldsize = @array.size
      @array = @array[XSIZE..-1].concat(@array[0...XSIZE])
    end

    # Moves the bottom-most row to the top.
    def move_down
      @array[-XSIZE..-1].each_with_index { |e, x| yield e, x } if block_given?
      @array = @array[-XSIZE..-1].concat(@array[0...-XSIZE])
    end

    def create_tiles
      # Screen fits exactly 15x10 tiles, but it has a configurable buffer around it
      # so the game has time to refresh without showing a black border during movement.
      tiles = []
      (TOTALSIZE).times { tiles << TileSprite.new($visuals.viewport) }
      @array = tiles
      startx = $visuals.map.real_x / -32 - XBUFFER
      starty = $visuals.map.real_y / -32 - YBUFFER
      for y in 0...YSIZE
        for x in 0...XSIZE
          mapx = startx + x
          mapy = starty + y
          idx = x + y * XSIZE
          @array[idx].real_x = $visuals.map.real_x + mapx * 32
          @array[idx].real_y = $visuals.map.real_y + mapy * 32
          draw_tile(@array[idx], mapx, mapy)
        end
      end
      $temp_bitmaps = nil
      # Don't dispose the bitmaps hash because tiles reference these instances; they're not clones.
    end

    def refresh_tiles
      return if empty?
      xdiff = @array[0].real_x.round / -32 - XBUFFER
      ydiff = @array[0].real_y.round / -32 - YBUFFER
      if ydiff > 0
        ydiff.times do
          move_up do |sprite|
            sprite.mapy += YSIZE
            sprite.real_y += 32 * YSIZE
            draw_tile(sprite, sprite.mapx, sprite.mapy)
          end
        end
        $temp_bitmaps = nil
      elsif ydiff < 0
        ydiff.abs.times do
          move_down do |sprite|
            sprite.mapy -= YSIZE
            sprite.real_y -= 32 * YSIZE
            draw_tile(sprite, sprite.mapx, sprite.mapy)
          end
        end
        $temp_bitmaps = nil
      end
      if xdiff > 0
        xdiff.times do
          move_left do |sprite|
            sprite.mapx += XSIZE
            sprite.real_x += 32 * XSIZE
            draw_tile(sprite, sprite.mapx, sprite.mapy)
          end
        end
        $temp_bitmaps = nil
      elsif xdiff < 0
        xdiff.abs.times do
          move_right do |sprite|
            sprite.mapx -= XSIZE
            sprite.real_x -= 32 * XSIZE
            draw_tile(sprite, sprite.mapx, sprite.mapy)
          end
        end
        temp_bitmaps = nil
      end
    end

    # Draws all tiles in a certain position to a sprite.
    # @param sprite [TileSprite] the tile sprite to draw to.
    # @param mapx [Fixnum] the x position of the tile on the map.
    # @param mapy [Fixnum] the y position of the tile on the map.
    def draw_tile(sprite, mapx, mapy)
      $temp_bitmaps ||= {}
      # Reset the sprite to a blank tilesprite
      sprite.clear
      sprite.mapx = mapx
      sprite.mapy = mapy
      # Reconfigure if it's a valid and visible tile
      if mapx >= 0 && mapx < $game.map.width && mapy >= 0 && mapy < $game.map.height
        id = $game.map.id
      elsif $game.map.connection
        mx, my = $game.map.connection[1], $game.map.connection[2]
        gx, gy = mx + mapx, my + mapy
        if gx >= 0 && gy >= 0
          maps = MKD::MapConnections.fetch.maps[$game.map.connection[0]]
          maps.keys.each do |x,y|
            mid = maps[[x, y]]
            next if mid == $game.map.id
            map = MKD::Map.fetch(mid)
            width, height = map.width, map.height
            if gx >= x && gy >= y && gx < x + width && gy < y + height
              #msgbox "(#{x},#{y},#{width},#{height}) <-> (#{gx},#{gy})"
              mapx = gx - x
              mapy = gy - y
              id = mid
              break
            end
          end
        end
      end
      if id
        if id != $game.map.id
          #msgbox "MapX: #{sprite.mapx}\nMapY: #{sprite.mapy}\nMap ID: #{id}\nX: #{mapx}\nY: #{mapy}"
        end
        for layer in 0...$game.maps[id].data.tiles.size
          tile_type, tile_id = $game.maps[id].data.tiles[layer][mapx + $game.maps[id].height * mapy]
          next if tile_type.nil?
          tileset_id = $game.maps[id].data.tilesets[tile_type]
          tileset = MKD::Tileset.fetch(tileset_id)
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

  # One sprite for one (x,y) position. Holds multiple sprites for multiple layers.
  class TileSprite
    attr_reader :real_x
    attr_reader :real_y
    attr_accessor :mapx
    attr_accessor :mapy

    def initialize(viewport)
      @sprites = [Sprite.new(viewport, {priority: 0, tile_id: 0})]
      @viewport = viewport
      @real_x = 0
      @real_y = 0
      @priority = 0
      @mapx = 0
      @mapy = 0
    end

    def real_x=(value)
      @real_x = value
      @sprites.each { |s| s.x = value.round if s }
    end

    def real_y=(value)
      @real_y = value
      @sprites.each { |s| s.y = value.round if s }
      @sprites.each { |s| s.z = s.y + s.hash[:priority] * 32 + 32 if s }
    end

    def priority=(value)
      @sprites.each { |s| s.z = s.y + s.hash[:priority] * 32 + 32 if s }
    end

    def clear
      @sprites.each do |s|
        if s
          s.bitmap = nil
          s.z = 0
        end
      end
    end

    def set(layer, bitmap, tile_id, priority = 0)
      if !@sprites[layer]
        @sprites[layer] = Sprite.new(@viewport)
        @sprites[layer].x = @real_x
        @sprites[layer].y = @real_y
      end
      @sprites[layer].bitmap = bitmap
      @sprites[layer].src_rect.width = 32
      @sprites[layer].src_rect.height = 32
      @sprites[layer].src_rect.x = tile_id % 8 * 32
      @sprites[layer].src_rect.y = (tile_id / 8).floor * 32
      @sprites[layer].z = @sprites[layer].y + priority * 32 + 32
      @sprites[layer].hash = {priority: priority, tile_id: tile_id}
    end
  end
end
