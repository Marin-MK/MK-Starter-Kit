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
      @speed = 2.2 # Has to be a float
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

    def direction_noanim=(value)
      unless [:down,:left,:right,:up].include?(value)
        raise "Invalid direction value #{value.inspect} - should be :down, :left, :right, or :up."
      end
      $visuals.player.set_direction_noanim(value) unless @direction == value
      @direction = value
    end

    def moving?
      return $visuals.player.moving?
    end

    def moving_up?
      return $visuals.player.moving_up?
    end

    def moving_down?
      return $visuals.player.moving_down?
    end

    def moving_right?
      return $visuals.player.moving_right?
    end

    def moving_left?
      return $visuals.player.moving_left?
    end

    def move_down
      if @direction != :down && @lastdir4 == 0
        self.direction = :down
        @downcount = 8
      elsif @downcount.nil? || @downcount == 0
        self.direction_noanim = :down if @direction != :down
        @y += 1
        @downcount = nil
      end
      @downcount -= 1 if @downcount
    end

    def move_left
      if @direction != :left && @lastdir4 == 0
        self.direction = :left
        @leftcount = 8
      elsif @leftcount.nil? || @leftcount == 0
        self.direction_noanim = :left if @direction != :left
        @x -= 1
        @leftcount = nil
      end
      @leftcount -= 1 if @leftcount
    end

    def move_right
      if @direction != :right && @lastdir4 == 0
        self.direction = :right
        @rightcount = 8
      elsif @rightcount.nil? || @rightcount == 0
        self.direction_noanim = :right if @direction != :right
        @x += 1
        @rightcount = nil
      end
      @rightcount -= 1 if @rightcount
    end

    def move_up
      if @direction != :up && @lastdir4 == 0
        self.direction = :up
        @upcount = 8
      elsif @upcount.nil? || @upcount == 0
        self.direction_noanim = :up if @direction != :up
        @y -= 1
        @upcount = nil
      end
      @upcount -= 1 if @upcount
    end

    def update
      if !moving? && !@wasmoving
        input = Input.dir4
        case input
        when 2
          move_down
        when 4
          move_left
        when 6
          move_right
        when 8
          move_up
        end
        @lastdir4 = input
      end
      @wasmoving = moving?
    end
  end
end


=begin
      mov = moving?
      puts mov
      if Input.press?(Input::DOWN) && !mov && !Input.press?(Input::UP)
        self.direction = :down if @wasmoving
        @downcount ||= 0
        if @direction != :down
          self.direction = :down
          @downcount = (((32 / @speed).ceil + 1) / 2.0).round
        elsif @downcount % ((32 / @speed).ceil + 1) == 0
          @y += 1
        else
          @downcount += 1
        end
      else
        @downcount = 0
      end

      if Input.press?(Input::UP) && !mov && !Input.press?(Input::DOWN)
        self.direction = :up if @wasmoving
        @upcount ||= 0
        if @direction != :up
          self.direction = :up
          @upcount = (((32 / @speed).ceil + 1) / 2.0).round
        elsif @upcount % ((32 / @speed).ceil + 1) == 0
          @y -= 1
        else
          @upcount += 1
        end
      else
        @upcount = 0
      end
=end

=begin
      if Input.press?(Input::DOWN) && !moving_up? && !Input.press?(Input::UP)
        @downcount ||= 0
        #self.direction = :down if @wasmoving
        if @downcount == 0 && @direction != :down && !moving?
          self.direction = :down
          @downcount = (((32 / @speed).ceil + 1) / 3.0).round
        elsif @downcount % ((32 / @speed).ceil + 1) == 0 && !moving_down? && !moving_up?
          @y += 1
        end
        @downcount += 1
      else
        @downcount = 0
      end

      if Input.press?(Input::UP) && !moving_down? && !Input.press?(Input::DOWN)
        @upcount ||= 0
        #self.direction = :up if @wasmoving
        if @upcount == 0 && @direction != :up && !moving?
          self.direction = :up
          @upcount = (((32 / @speed).ceil + 1) / 3.0).round
        elsif @upcount % ((32 / @speed).ceil + 1) == 0 && !moving_up? && !moving_down?
          @y -= 1
        end
        @upcount += 1
      else
        @upcount = 0
      end
=end

=begin


      # Up and down override left and right
      dominant = moving_up? || moving_down? || Input.press?(Input::UP) || Input.press?(Input::DOWN)
      if Input.press?(Input::LEFT) && !moving_right? && !Input.press?(Input::RIGHT) && !dominant
        @leftcount ||= 0
        self.direction = :left if @wasmoving
        if @leftcount == 0 && @direction != :left && !moving?
          self.direction = :left
          @leftcount = (((32 / @speed).ceil + 1) / 3.0).round
        elsif @leftcount % ((32 / @speed).ceil + 1) == 0 && !moving_left?
          @x -= 1
        end
        @leftcount += 1
      else
        @leftcount = 0
      end

      # Up and down override left, but they don't override right if down and up are both pressed
      dominant = false if Input.press?(Input::DOWN) && Input.press?(Input::UP)
      if Input.press?(Input::RIGHT) && !moving_left? && !Input.press?(Input::LEFT) && !dominant
        @rightcount ||= 0
        self.direction = :right if @wasmoving
        if @rightcount == 0 && @direction != :right && !moving?
          self.direction = :right
          @rightcount = (((32 / @speed).ceil + 1) / 3.0).round
        elsif @rightcount % ((32 / @speed).ceil + 1) == 0 && !moving_right?
          @x += 1
        end
        @rightcount += 1
      else
        @rightcount = 0
      end
 
=end