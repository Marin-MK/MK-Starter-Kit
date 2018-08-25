class Game
  class Player
    attr_accessor :map_id
    attr_accessor :x
    attr_accessor :y
    attr_accessor :graphic_name
    attr_accessor :direction

    def initialize
      @map_id = 0
      @x = 0
      @y = 0
      @direction = :down
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
      if Input.trigger?(Input::DOWN)
        self.direction = :down
      end
      if Input.trigger?(Input::LEFT)
        self.direction = :left
      end
      if Input.trigger?(Input::RIGHT)
        self.direction = :right
      end
      if Input.trigger?(Input::UP)
        self.direction = :up
      end
    end
  end
end