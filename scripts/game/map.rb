class Game
  class Map
    attr_accessor :id
    attr_accessor :data
    attr_accessor :width
    attr_accessor :height

    def initialize(id = 0)
      @id = id
      @data = MKD::Map.fetch(id)
      @width = @data.width
      @height = @data.height
      @tiles = @data.tiles
      @passabilities = @data.passabilities
      # Fetch passability data from the tileset
      @tileset_passabilities = MKD::Tileset.fetch(@data.tileset_id).passabilities
      Visuals::Map.create(self)
    end

    def passable?(x, y, direction = nil)
      return false if x < 0 || x >= @width || y < 0 || y >= @height
      validate x => Fixnum, y => Fixnum, direction => [Fixnum, Symbol, NilClass]
      direction = get_direction(direction) if direction.is_a?(Symbol)
      unless @passabilities[x + y * @height].nil?
        val = @passabilities[x + y * @height]
        return false if val == 0
        return true if val == 15 || !direction
        dirbit = [1, 2, 4, 8][(direction / 2) - 1]
        return (val & dirbit) == dirbit
      end
      for layer in 0...@tiles.size
        tile_id = @tiles[layer][x + y * @height]
        next unless tile_id
        val = @tileset_passabilities[tile_id % 8 + (tile_id / 8).floor * 8]
        return false if val == 0
        next unless direction
        dirbit = [1, 2, 4, 8][(direction / 2) - 1]
        return false if (val & dirbit) != dirbit
      end
      return true
    end

    def update

    end
  end
end