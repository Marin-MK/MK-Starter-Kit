class Game
  class Player
    attr_accessor :map_id
    attr_accessor :x
    attr_accessor :y
    attr_accessor :graphic_name
    attr_accessor :direction
    attr_accessor :speed
    attr_accessor :priority
    
    def initialize
      @map_id = 0
      @x = 0
      @y = 0
      @direction = :down
      @speed = 2.2 # Has to be a float
      @graphic_name = "boy"
      @running = false
      @runcount = 0
      @priority = 1
      Visuals::Player.create(self)
    end

    # Changes the player's direction with a turn animation.
    def direction=(value)
      unless [:down,:left,:right,:up].include?(value)
        raise "Invalid direction value #{value.inspect} - should be :down, :left, :right, or :up."
      end
      $visuals.player.set_direction(value) unless @direction == value
      @direction = value
    end

    # Changes the player's direction without a turn animation.
    def direction_noanim=(value)
      unless [:down,:left,:right,:up].include?(value)
        raise "Invalid direction value #{value.inspect} - should be :down, :left, :right, or :up."
      end
      $visuals.player.set_direction_noanim(value) unless @direction == value
      @direction = value
    end

    # Returns whether or not the player is moving.
    def moving?
      return $visuals.player.moving?
    end

    def running?
      return @running
    end

    def can_run?
      return moving?
    end

    def update
      @fake_move = false
      oldrun = @running
      if Input.press?(Input::B)
        @runcount = 7 if !moving? && !@wasmoving && @runcount == 0
        @runcount += 1
      else
        @runcount = 0
      end
      @running = @runcount > 7 && can_run?
      @speed = @running ? PLAYERRUNSPEED : PLAYERWALKSPEED
      if oldrun != @running # Walking to running or running to walking
        @graphic_name = @running ? "boy_run" : "boy"
      end
      if !moving? && !@wasmoving
        case input = Input.dir4
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

    # Publicly available for $visuals.player
    attr_reader :fake_move

    # Moves the player down one tile. Not to be manually called.
    private def move_down
      if @direction != :down && @lastdir4 == 0 && !$visuals.player.fake_anim
        self.direction = :down
        @downcount = 8
      elsif @downcount.nil? || @downcount == 0 || @fake_move
        self.direction_noanim = :down if @direction != :down
        if $game.map.passable?(@x, @y + 1, :down)
          @y += 1
        else
          @fake_move = true
        end
        @downcount = nil
      end
      @downcount -= 1 if @downcount
    end

    # Moves the player down left tile. Not to be manually called.
    private def move_left
      if @direction != :left && @lastdir4 == 0 && !$visuals.player.fake_anim
        self.direction = :left
        @leftcount = 8
      elsif @leftcount.nil? || @leftcount == 0 || @fake_move
        self.direction_noanim = :left if @direction != :left
        if $game.map.passable?(@x - 1, @y, :left)
          @x -= 1
        else
          @fake_move = true
        end
        @leftcount = nil
      end
      @leftcount -= 1 if @leftcount
    end

    # Moves the player down right tile. Not to be manually called.
    private def move_right
      if @direction != :right && @lastdir4 == 0 && !$visuals.player.fake_anim
        self.direction = :right
        @rightcount = 8
      elsif @rightcount.nil? || @rightcount == 0 || @fake_move
        self.direction_noanim = :right if @direction != :right
        if $game.map.passable?(@x + 1, @y, :right)
          @x += 1
        else
          @fake_move = true
        end
        @rightcount = nil
      end
      @rightcount -= 1 if @rightcount
    end

    # Moves the player up one tile. Not to be manually called.
    private def move_up
      if @direction != :up && @lastdir4 == 0 && !$visuals.player.fake_anim
        self.direction = :up
        @upcount = 8
      elsif @upcount.nil? || @upcount == 0 || @fake_move
        self.direction_noanim = :up if @direction != :up
        if $game.map.passable?(@x, @y - 1, :up)
          @y -= 1
        else
          @fake_move = true
        end
        @upcount = nil
      end
      @upcount -= 1 if @upcount
    end
  end
end