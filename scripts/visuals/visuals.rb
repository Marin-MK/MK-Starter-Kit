class Visuals
  # @return [Hash<Visuals::Map>] the list of maps stored by ID.
  attr_accessor :maps
  # @return [Viewport] the main viewport for all maps and events.
  attr_accessor :viewport
  # @return [Visuals::Player] the player object.
  attr_accessor :player
  # @return [TileArray<TileSprite>] the global tilemap.
  attr_accessor :tiles

  # Creates a new Visuals object.
  def initialize
    @maps = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  end

  # @return [Visuals::Map] the current map object.
  def map
    return @maps[$game.map.id]
  end

  # Updates the maps and player.
  def update
    @maps.values.each(&:update)
    @player.update
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


$visuals = Visuals.new
