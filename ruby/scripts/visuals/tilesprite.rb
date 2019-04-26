class Visuals
  class MapRenderer
    # One sprite for one (x,y) position. Holds multiple sprites for multiple layers.
    class TileSprite
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
      end

      def real_x=(value)
        value = value.round(6)
        @real_x = value
        if value < 0
          value = value.round
        else
          value = value.floor
        end
        @sprites.each_value { |s| s.x = value.round if s }
      end

      def real_y=(value)
        value = value.round(6)
        @real_y = value
        if value < 0
          value = value.round
        else
          value = value.floor
        end
        @sprites.each_value { |s| s.y = value if s }
        @sprites.each_value { |s| s.z = s.y + s.hash[:priority] * 32 + 32 if s && s.hash[:priority] && !s.hash[:special] }
      end

      def priority=(value)
        @sprites.each_value { |s| s.z = s.y + s.hash[:priority] * 32 + 32 if s && s.hash[:priority] }
      end

      def clear
        @sprites.each_value do |s|
          if s && !s.hash[:special]
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
end
