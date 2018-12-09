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
      @tiles.each { |e| e.real_x -= diff }
      @real_x = value
      refresh_tiles
      @events.values.each { |e| e.sprite.x = @real_x + e.relative_x }
    end

    def real_y=(value)
      diff = @real_y - value
      @tiles.each { |e| e.real_y -= diff }
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
      if @tiles
        @startx = @tiles[0].real_x.round / -32 - 2
        @starty = @tiles[0].real_y.round / -32 - 2
        if @starty > 0
          @starty.times do
            @tiles.move_up do |sprite|
              sprite.mapy += 14
              sprite.real_y += 32 * 14
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
          $temp_tilesets = nil
          $temp_bitmaps = nil
        elsif @starty < 0
          @starty.abs.times do
            @tiles.move_down do |sprite|
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
            @tiles.move_left do |sprite|
              sprite.mapx += 19
              sprite.real_x += 32 * 19
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
          $temp_tilesets = nil
          $temp_bitmaps = nil
        elsif @startx < 0
          @startx.abs.times do
            @tiles.move_right do |sprite|
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
        @tiles = TileArray.new(tiles)
        @startx = @real_x / -32 - 2
        @starty = @real_y / -32 - 2
        for y in 0...14
          for x in 0...19
            mapx = @startx + x
            mapy = @starty + y
            idx = x + y * 19
            @tiles[idx].real_x = @real_x + mapx * 32
            @tiles[idx].real_y = @real_y + mapy * 32
            draw_tile(@tiles[idx], mapx, mapy)
          end
        end
        $temp_tilesets = nil
        $temp_bitmaps = nil
        # Don't dispose the bitmaps hash because tiles reference these instances; they're not clones.
        @startx = @tiles[0].real_x / -32 - 2
        @starty = @tiles[0].real_y / -32 - 2
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

# Rectangular array that can shift in each direction. Used for the tile sprites in the map renderer.
# Principle:
# 1 2 3                      3 1 2
# 4 5 6  ->  move_right  ->  6 4 5
# 7 8 9                      9 7 8
class TileArray
  attr_accessor :array

  def initialize(array)
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

  # Moves the right-most column to the left.
  def move_right
    for i in 0...@array.size
      if (i + 1) % 19 == 0
        v = @array.delete_at(i)
        yield v if block_given?
        @array.insert(i - 18, v)
      end
    end
  end

  # Moves the left-most column to the right.
  def move_left
    for i in 0...@array.size
      if i % 19 == 0
        v = @array.delete_at(i)
        yield v if block_given?
        @array.insert(i + 18, v)
      end
    end
  end

  # Moves the top-most row to the bottom.
  def move_up
    @array[0...19].each_with_index { |e, x| yield e, x } if block_given?
    oldsize = @array.size
    @array = @array[19..-1].concat(@array[0...19])
  end

  # Moves the bottom-most row to the top.
  def move_down
    @array[-19..-1].each_with_index { |e, x| yield e, x } if block_given?
    @array = @array[-19..-1].concat(@array[0...-19])
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
