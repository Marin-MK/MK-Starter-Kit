class Visuals
  class Map
    class Event
      def self.create(game_event)
        $visuals.maps[game_event.map_id].events << self.new(game_event)
      end

      def initialize(game_event)
        @game_event = game_event
        @sprite = Sprite.new($visuals.viewport)
        @sprite.z = 10 + 3 * @game_event.settings.priority
        update
      end

      def update
        map = $visuals.maps[@game_event.map_id]
        @sprite.x = map.real_x + @game_event.x * 32 + 16
        @sprite.y = map.real_y + @game_event.y * 32 + 32
        if @oldstate != @game_event.active_state
          state = @game_event.active_state
          graphic = state.graphic
          if graphic.type == 0 # Filename with src_rect
            @sprite.bitmap = Bitmap.new(graphic.param)
            @sprite.src_rect.width = @sprite.bitmap.width / 4
            @sprite.src_rect.height = @sprite.bitmap.height / 4
            @sprite.src_rect.y = (graphic.direction / 2 - 1) * @sprite.src_rect.height
          elsif graphic.type == 1 # Filename without src_rect
            @sprite.bitmap = Bitmap.new(graphic.param)
          elsif graphic.type == 2 # Tile

          end
          @sprite.ox = @sprite.src_rect.width / 2
          @sprite.oy = @sprite.src_rect.height
        end
        @oldstate = @game_event.active_state
      end
    end
  end
end