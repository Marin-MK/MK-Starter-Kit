class Game
  class Player
    attr_accessor :map_id
    attr_accessor :x
    attr_accessor :y
    attr_accessor :graphic_name
    attr_accessor :direction
    attr_accessor :speed

    def initialize
      @map_id = 0
      @x = 0
      @y = 0
      @direction = :down
      @speed = 3.0 # Has to be a float
      @graphic_name = "boy"
      Visuals::Player.create(self)
    end

    def direction=(value)
      unless [:down,:left,:right,:up].include?(value)
        raise "Invalid direction value #{value.inspect} - should be :down, :left, :right, or :up."
      end
      $visuals.player.set_direction(value) unless @direction == value
      @direction = value
    end

    def update
      # Movement
      @downcount += 1 if @downcount
      @leftcount += 1 if @leftcount
      @rightcount += 1 if @rightcount
      @upcount += 1 if @upcount

      if Input.press?(Input::DOWN) && !$visuals.player.moving_up?
        @downcount ||= 0
        if @downcount == 0
          if @direction == :down
            @downcount = (32 / @speed).ceil + 1
          else
            self.direction = :down
          end
        end
        if @downcount > 0 && @downcount % ((32 / @speed).ceil + 1) == 0
          @y += 1
        end
      elsif !$visuals.player.moving_down?
        @downcount = nil
      end

      if Input.press?(Input::LEFT) && !$visuals.player.moving_right?
        @leftcount ||= 0
        if @leftcount == 0
          if @direction == :left
            @leftcount = (32 / @speed).ceil + 1
          else
            self.direction = :left
          end
        end
        if @leftcount > 0 && @leftcount % ((32 / @speed).ceil + 1) == 0
          @x -= 1
        end
      elsif !$visuals.player.moving_left?
        @leftcount = nil
      end

      if Input.press?(Input::RIGHT) && !$visuals.player.moving_left?
        @rightcount ||= 0
        if @rightcount == 0
          if @direction == :right
            @rightcount = (32 / @speed).ceil + 1
          else
            self.direction = :right
          end
        end
        if @rightcount > 0 && @rightcount % ((32 / @speed).ceil + 1) == 0
          @x += 1
        end
      elsif !$visuals.player.moving_right?
        @rightcount = nil
      end

      if Input.press?(Input::UP) && !$visuals.player.moving_down?
        @upcount ||= 0
        if @upcount == 0
          if @direction == :up
            @upcount = (32 / @speed).ceil + 1
          else
            self.direction = :up
          end
        end
        if @upcount > 0 && @upcount % ((32 / @speed).ceil + 1) == 0
          @y -= 1
        end
      elsif !$visuals.player.moving_up?
        @upcount = nil
      end
    end
  end
end