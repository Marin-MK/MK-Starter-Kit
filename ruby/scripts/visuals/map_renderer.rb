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

    attr_accessor :array

    def initialize(array = [])
      @array = array
    end

    def dispose
      @array.each(&:dispose)
      @array = nil
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

    def move_horizontal(px)
      @array.each { |e| e.real_x -= px }
      $visuals.maps.each_value { |map| map.real_x -= px }
      $visuals.map_renderer.refresh_tiles
    end

    def move_vertical(px)
      @array.each { |e| e.real_y -= px }
      $visuals.maps.each_value { |map| map.real_y -= px }
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
      (XSIZE * YSIZE).times { tiles << TileSprite.new($visuals.viewport) }
      @array = tiles
      startx = $game.player.x - XSIZE / 2
      starty = $game.player.y - YSIZE / 2
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
      # Since sprites are moved when the player moves, they will eventually go off-screen.
      # This difference is the number of rows/columns that are off-screen, and should thus be re-rendered.
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
    # NOTE: If the player is not centered to the screen, it will still return the center tile.
    def player_tile
      return @array[XSIZE * (YSIZE / 2) + (XSIZE / 2.0).floor]
    end

    # Adjusts the map renderer coordinates to treat the new main map as the relative parent map
    def map_transition(oldx, oldy)
      xoffset = 0
      if oldx > $game.player.x
        xoffset = -1
      elsif oldx < $game.player.x
        xoffset = 1
      end
      startx = $game.player.x - XSIZE / 2 + xoffset
      starty = $game.player.y - YSIZE / 2
      for y in 0...YSIZE
        for x in 0...XSIZE
          @array[x + y * XSIZE].mapx = startx + x
          @array[x + y * XSIZE].mapy = starty + y
        end
      end
    end

    # Draws all tiles in a certain position to a sprite.
    # @param sprite [TileSprite] the tile sprite to draw to.
    # @param mapx [Integer] the x position of the tile on the map.
    # @param mapy [Integer] the y position of the tile on the map.
    def draw_tile(sprite, mapx, mapy)
      # Reset the sprite to a blank tilesprite
      sprite.clear
      sprite.mapx = mapx
      sprite.mapy = mapy
      # Reconfigure if it's a valid and visible tile
      if mapx >= 0 && mapx < $game.map.width && mapy >= 0 && mapy < $game.map.height
        id = $game.map.id
      elsif !$game.map.connections.empty?
        id, mapx, mapy = $game.get_map_from_connection($game.map, mapx, mapy)
        if !$game.is_map_loaded?(id)
          id = nil
        end
      end
      if id
        for layer in 0...$game.maps[id].data.tiles.size
          tile_data = $game.maps[id].data.tiles[layer][mapx + $game.maps[id].width * mapy]
          sprite.set(layer, id, tile_data)
        end
      end
    end

    # Updates all tiles (used for autotile animation)
    def update
      @i ||= 0
      @array.each { |tile| tile.update(@i) }
      @i += 1
    end
  end
end
