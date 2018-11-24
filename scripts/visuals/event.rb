class Visuals
  class Map
    class Event
      def self.create(game_event)
        $visuals.maps[game_event.map_id].events[game_event.id] = self.new(game_event)
      end

      attr_accessor :sprite
      attr_accessor :relative_x
      attr_accessor :relative_y

      def initialize(game_event)
        @game_event = game_event
        @sprite = Sprite.new($visuals.viewport)
        @sprite.z = 10 + 3 * @game_event.settings.priority
        @moveroute_ready = true
        @xdist = []
        @xtrav = []
        @xstart = []
        @ydist = []
        @ytrav = []
        @ystart = []
        @anim = []
        @relative_x = @game_event.x * 32 + 16
        @relative_y = @game_event.y * 32 + 32
        @moveroute_wait = 0
        update
      end

      def update
        if @oldpage != @game_event.current_page
          page = @game_event.current_page
          graphic = page.graphic
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
        @oldpage = @game_event.current_page

        # Queues movement commands
        if @moveroute_wait > 0
          @moveroute_wait -= 1
          next_move_command if @moveroute_wait == 0
        end
        if @moveroute_ready
          move = @game_event.moveroute[0]
          if move
            @moveroute_ready = false
            name = move
            name = move[0] if move.is_a?(Array)
            case name
            when :down
              @ydist << 32
              @ytrav << 0
              @ystart << (@ystart[0] ? @ystart.last + @ydist.last : @relative_y)
              @anim << [0, 16]
              @game_event.direction = 2
              @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
              @game_event.y += 1
            when :left
              @xdist << -32
              @xtrav << 0
              @xstart << (@xstart[0] ? @xstart.last + @xdist.last : @relative_x)
              @anim << [0, -16]
              @game_event.direction = 4
              @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
              @game_event.x -= 1
            when :right
              @xdist << 32
              @xtrav << 0
              @xstart << (@xstart[0] ? @xstart.last + @xdist.last : @relative_x)
              @anim << [0, 16]
              @game_event.direction = 6
              @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
              @game_event.x += 1
            when :up
              @ydist << -32
              @ytrav << 0
              @ystart << (@ystart[0] ? @ystart.last + @ydist.last : @relative_y)
              @anim << [0, -16]
              @game_event.direction = 8
              @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
              @game_event.y -= 1
            when :turn_down
              @game_event.direction = 2
              @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
              next_move_command
            when :turn_left
              @game_event.direction = 4
              @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
              next_move_command
            when :turn_right
              @game_event.direction = 6
              @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
              next_move_command
            when :turn_up
              @game_event.direction = 8
              @sprite.src_rect.y = (@game_event.direction / 2 - 1) * @sprite.src_rect.height
              next_move_command
            when :wait
              @moveroute_wait = move[1]
            else
              raise "Invalid move route command #{move.inspect}"
            end
          end
        end

        # Executes the horizontal movement
        if @xdist[0] && @xtrav[0] && @xstart[0]
          if @xtrav[0].abs < @xdist[0].abs
            dist = @game_event.speed * (@xdist[0] < 0 ? -1 : 1)
            @xtrav[0] += dist
            @xtrav[0] = @xdist[0] < 0 ? [@xtrav[0], @xdist[0]].max : [@xtrav[0], @xdist[0]].min
            @relative_x = @xstart[0] + @xtrav[0]
            if @anim[0].size > 0 && (@xdist[0] > 0 && @xtrav[0] > @anim[0][0] || @xdist[0] < 0 && @xtrav[0] < @anim[0][0])
              @sprite.src_rect.x += @sprite.src_rect.width
              @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
              @anim[0].delete_at(0)
            end
          else
            @xtrav.delete_at(0)
            @xdist.delete_at(0)
            @xstart.delete_at(0)
            @anim.delete_at(0)
            next_move_command
          end
        end
        # Executes the vertical movement
        if @ydist[0] && @ytrav[0] && @ystart[0]
          if @ytrav[0].abs < @ydist[0].abs
            dist = @game_event.speed * (@ydist[0] < 0 ? -1 : 1)
            @ytrav[0] += dist
            @ytrav[0] = @ydist[0] < 0 ? [@ytrav[0], @ydist[0]].max : [@ytrav[0], @ydist[0]].min
            @relative_y = @ystart[0] + @ytrav[0]
            if @anim[0].size > 0 && (@ydist[0] > 0 && @ytrav[0] > @anim[0][0] || @ydist[0] < 0 && @ytrav[0] < @anim[0][0])
              @sprite.src_rect.x += @sprite.src_rect.width
              @sprite.src_rect.x = 0 if @sprite.src_rect.x >= @sprite.bitmap.width
              @anim[0].delete_at(0)
            end
          else
            @ytrav.delete_at(0)
            @ydist.delete_at(0)
            @ystart.delete_at(0)
            @anim.delete_at(0)
            next_move_command
          end
        end

        # Sets the sprite's on-screen location based on the map's offset and the coordinates of the sprite relative to the map.
        map = $visuals.maps[@game_event.map_id]
        @sprite.x = map.real_x + @relative_x
        @sprite.y = map.real_y + @relative_y
      end

      def next_move_command
        @moveroute_ready = true
        @game_event.moveroute.delete_at(0)
      end
    end
  end
end