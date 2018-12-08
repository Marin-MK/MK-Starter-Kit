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

    # Creates a sprite for the map object.
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

    def refresh_tiles
      if @tiles
        @startx = @tiles[0].x / -32 - 2
        @starty = @tiles[0].y / -32 - 2
        if @starty > 0
          @starty.times do
            @tiles.move_up do |sprite|
              sprite.mapy += 14
              sprite.real_y += 32 * 14
              sprite.bitmap = nil
              sprite.tile_id = nil
              sprite.z = 0
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
        elsif @starty < 0
          @starty.abs.times do
            @tiles.move_down do |sprite|
              sprite.mapy -= 14
              sprite.real_y -= 32 * 14
              sprite.bitmap = nil
              sprite.tile_id = nil
              sprite.z = 0
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
        end
        if @startx > 0
          @startx.times do
            @tiles.move_left do |sprite|
              sprite.mapx += 19
              sprite.real_x += 32 * 19
              sprite.bitmap = nil
              sprite.tile_id = nil
              sprite.z = 0
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
        elsif @startx < 0
          @startx.abs.times do
            @tiles.move_right do |sprite|
              sprite.mapx -= 19
              sprite.real_x -= 32 * 19
              sprite.bitmap = nil
              sprite.tile_id = nil
              sprite.z = 0
              draw_tile(sprite, sprite.mapx, sprite.mapy)
            end
          end
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
            @tiles[idx].mapx = mapx
            @tiles[idx].mapy = mapy
            @tiles[idx].tile_id = nil
            draw_tile(@tiles[idx], mapx, mapy)
          end
        end
        $temp_tilesets = nil
        $temp_bitmaps = nil
        # Don't dispose the bitmaps hash because tiles reference these instances; they're not clones.
        @startx = @tiles[0].x / -32 - 2
        @starty = @tiles[0].y / -32 - 2
      end
    end

    def draw_tile(sprite, mapx, mapy)
      $temp_tilesets ||= {}
      $temp_bitmaps ||= {}
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
          sprite.bitmap = bmp
          sprite.src_rect.width = 32
          sprite.src_rect.height = 32
          sprite.src_rect.x = tile_id % 8 * 32
          sprite.src_rect.y = (tile_id / 8).floor * 32
          sprite.tile_id = tile_id
          sprite.z = 10
        end
      end
    end
  end
end

# Rectangular array that can shift in each direction. Used for the tile sprites in the map renderer.
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

  def move_right
    for i in 0...@array.size
      if (i + 1) % 19 == 0
        v = @array.delete_at(i)
        yield v if block_given?
        @array.insert(i - 18, v)
      end
    end
  end

  def move_left
    for i in 0...@array.size
      if i % 19 == 0
        v = @array.delete_at(i)
        yield v if block_given?
        @array.insert(i + 18, v)
      end
    end
  end

  def move_up
    @array[0...19].each_with_index { |e, x| yield e, x } if block_given?
    oldsize = @array.size
    @array = @array[19..-1].concat(@array[0...19])
  end

  def move_down
    @array[-19..-1].each_with_index { |e, x| yield e, x } if block_given?
    @array = @array[-19..-1].concat(@array[0...-19])
  end
end

class TileSprite < Sprite
  attr_reader :real_x
  attr_reader :real_y
  attr_accessor :mapx
  attr_accessor :mapy
  attr_accessor :tile_id

  def initialize(viewport)
    super(viewport)
    @real_x = 0
    @real_y = 0
  end

  def real_x=(value)
    @real_x = value
    self.x = value.round
  end

  def real_y=(value)
    @real_y = value
    self.y = value.round
  end
end
