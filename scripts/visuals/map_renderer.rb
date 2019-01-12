class Visuals
  # Rectangular array that can shift in each direction. Used for the tile sprites in the map renderer.
  # Principle:
  # 1 2 3                      3 1 2
  # 4 5 6  ->  move_right  ->  6 4 5
  # 7 8 9                      9 7 8
  class MapRenderer
    TILECOUNTX = (SCREENWIDTH / 32.0).ceil
    TILECOUNTY = (SCREENHEIGHT / 32.0).ceil

    XSIZE = TILECOUNTX + 2
    YSIZE = TILECOUNTY + 2
    TOTALSIZE = XSIZE * YSIZE

    GRIDBITMAP = Bitmap.new(32, 32)
    for x in 0...32
      for y in 0...32
        next unless x % 32 == 0 || y % 32 == 0
        GRIDBITMAP.set_pixel(x, y, Color.new(0, 0, 0))
      end
    end

    attr_accessor :array
    attr_reader :show_grid

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

    def move_x(diff)
      @array.each { |e| e.real_x -= diff }
      $visuals.map_renderer.refresh_tiles
    end

    def move_y(diff)
      @array.each { |e| e.real_y -= diff }
      $visuals.map_renderer.refresh_tiles
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

    # Moves the top-most row to the bottom.
    def move_up
      @array[0...XSIZE].each_with_index { |e, x| yield e } if block_given?
      @array = @array[XSIZE..-1].concat(@array[0...XSIZE])
    end

    # Moves the bottom-most row to the top.
    def move_down
      @array[-XSIZE..-1].each_with_index { |e, x| yield e } if block_given?
      @array = @array[-XSIZE..-1].concat(@array[0...-XSIZE])
    end

    # Initializes the tile array based on the currently active map.
    def create_tiles
      # Screen fits exactly 15x10 tiles (for 480x320), but it has a buffer around it
      # so the game has time to refresh without showing a black border during movement.
      tiles = []
      (TOTALSIZE).times { tiles << TileSprite.new($visuals.viewport) }
      @array = tiles
      startx = $visuals.map.real_x / -32 - 1
      starty = $visuals.map.real_y / -32 - 1
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

    # Determines if new tiles should be rendered and if so, renders them.
    def refresh_tiles
      return if empty?
      xdiff = @array[0].real_x.round / -32 - 1
      ydiff = @array[0].real_y.round / -32 - 1
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

    # @return [TileSprite] the tile the player would be standing on if the player is centered.
    # If the player is not centered to the screen, it will still return the center tile.
    def player_tile
      return @array[XSIZE * (YSIZE / 2) + (XSIZE / 2.0).floor]
    end

    # Adjusts the map renderer to center on the player.
    def adjust_to_player(x, y)
      xsmall = x < 0
      ysmall = y < 0
      xgreat = x >= $game.map.width
      ygreat = y >= $game.map.height
      t = player_tile
      diffx = t.mapx - $game.player.x
      diffx += xgreat ? 1 : xsmall ? -1 : 0
      diffy = t.mapy - $game.player.y
      diffy += ygreat ? 1 : ysmall ? -1 : 0
      self.each do |sprite|
        sprite.mapx -= diffx
        sprite.mapy -= diffy
      end
      $game.player.x += xsmall ? 1 : xgreat ? -1 : 0
      $game.player.y += ysmall ? 1 : ygreat ? -1 : 0
      $visuals.player.skip_movement
    end

    def toggle_grid
      if @show_grid
        self.show_grid = false
      else
        self.show_grid = true
      end
    end

    # Changes what the show_grid variable is set to. If true, a grid will be displayed on the map on layer 1000.
    # If false, it will delete any remaining grid tiles and turn the variable off again.
    def show_grid=(value)
      old = @show_grid
      @show_grid = value
      if old != @show_grid
        @array.each do |tile|
          if @show_grid
            if !tile.sprites[999]
              tile.sprites[999] = Sprite.new($visuals.viewport, {special: true})
              tile.sprites[999].bitmap = GRIDBITMAP
              tile.sprites[999].x = tile.sprites[0].x
              tile.sprites[999].y = tile.sprites[0].y
              tile.sprites[999].z = 999
            end
          else
            if tile.sprites[999]
              tile.sprites[999].dispose
              tile.sprites.delete(999)
            end
          end
        end
      end
    end

    # Draws all tiles in a certain position to a sprite.
    # @param sprite [TileSprite] the tile sprite to draw to.
    # @param mapx [Integer] the x position of the tile on the map.
    # @param mapy [Integer] the y position of the tile on the map.
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
        id, mapx, mapy = $game.get_map_from_connection($game.map, mapx, mapy)
      end
      if id
        for layer in 0...$game.maps[id].data.tiles.size
          tile_type, tile_id = $game.maps[id].data.tiles[layer][mapx + $game.maps[id].width * mapy]
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
end
