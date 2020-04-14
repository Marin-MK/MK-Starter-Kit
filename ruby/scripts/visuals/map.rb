class Visuals
  # The visual component of Game::Map objects.
  class Map
    # Creates a new map linked to the map object.
    # @param game_map [Game::Map] the map object.
    def self.create(game_map, real_x = 0, real_y = 0)
      $visuals.maps[game_map.id] = self.new(game_map, real_x, real_y)
    end

    # @return [Hash<Visuals::Event>] the hash of event visuals.
    attr_accessor :events
    # @return [Integer] the x position of the top-left corner of the map.
    attr_reader :real_x
    # @return [Integer] the y position of the top-left corner of the map.
    attr_reader :real_y
    # @return [Integer] the ID of this map.
    attr_reader :id

    def real_x=(value)
      @real_x = value
      @overlays.each { |o| o[0].x = @real_x }
      @events.values.each { |e| e.sprite.x = @real_x + e.relative_x }
    end

    def real_y=(value)
      @real_y = value
      @overlays.each { |o| o[0].y = @real_y }
      @events.values.each { |e| e.sprite.y = @real_y + e.relative_y }
    end

    # Creates a new Map object.
    def initialize(game_map, x = 0, y = 0)
      @game_map = game_map
      @id = @game_map.id
      @real_x = Graphics.width / 2 - 16 + 32 * x
      @real_y = Graphics.height / 2 - 16 + 32 * y
      @overlays = @game_map.data.panoramas.map { |pan|
        # Creates the sprites for the map's panoramas
        s = Sprite.new($visuals.viewport)
        s.bitmap = Bitmap.new("gfx/panoramas/#{pan.filename}");
        s.src_rect.width = [s.bitmap.width, @game_map.width * 32].min
        s.src_rect.height = [s.bitmap.height, @game_map.height * 32].min
        dir = pan.animate_direction
        s.src_rect.x = pan.pattern_repeat_interval if dir == :downright || dir == :right || dir == :upright
        s.src_rect.y = pan.pattern_repeat_interval if dir == :downleft || dir == :down || dir == :downright
        s.x = real_x
        s.y = real_y
        s.z = -1
        next [s, pan, 0]
      }.concat(@game_map.data.fogs.map { |fog|
        # Creates the sprites for the map's fogs
        s = Sprite.new($visuals.viewport)
        s.bitmap = Bitmap.new("gfx/fogs/#{fog.filename}");
        s.src_rect.width = [s.bitmap.width, @game_map.width * 32].min
        s.src_rect.height = [s.bitmap.height, @game_map.height * 32].min
        dir = fog.animate_direction
        s.src_rect.x = fog.pattern_repeat_interval if dir == :downright || dir == :right || dir == :upright
        s.src_rect.y = fog.pattern_repeat_interval if dir == :downleft || dir == :down || dir == :downright
        s.x = real_x
        s.y = real_y
        s.z = 999999
        next [s, fog, 0]
      })
      @events = {}
    end

    def dispose
      @events.each { |e| e.dispose if !e.disposed? }
      @events.clear
    end

    # Updates all this map's events.
    # Updates panorama and fog animations
    def update(*args)
      @events.each_value(&:update) unless args.include?(:no_events)
      @overlays.each do |o|
        # Animates scrolling fogs/panoramas
        next if o[1].animate_speed.nil? || o[1].animate_speed < 1
        if o[2] % o[1].animate_speed == 0
          s = o[0]
          dir = o[1].animate_direction
          if dir == :upright || dir == :up || dir == :upleft
            s.src_rect.y += 1
          end
          if dir == :upleft || dir == :left || dir == :downleft
            s.src_rect.x += 1
          end
          if dir == :downleft || dir == :down || dir == :downright
            s.src_rect.y -= 1
          end
          if dir == :downright || dir == :right || dir == :upright
            s.src_rect.x -= 1
          end
          s.src_rect.x = o[1].pattern_repeat_interval if s.src_rect.x <= 0
          s.src_rect.x = 1 if s.src_rect.x > o[1].pattern_repeat_interval
          s.src_rect.y = o[1].pattern_repeat_interval if s.src_rect.y <= 0
          s.src_rect.y = 1 if s.src_rect.y > o[1].pattern_repeat_interval
        end
        o[2] += 1
      end
    end
  end
end
