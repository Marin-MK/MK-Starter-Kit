class Game
  # The logical component of player objects.
  class Player
    # @return [Integer] the ID of the map the player is currently on.
    attr_accessor :map_id
    # @return [Integer] the x position of the player.
    attr_accessor :x
    # @return [Integer] the y position of the player.
    attr_accessor :y
    # @return [String] the name of the graphic the player currently has applied.
    attr_accessor :graphic_name
    # @return [Integer] the direction the player is currently facing in.
    attr_accessor :direction
    # @return [Float] how fast the player can move.
    attr_accessor :speed

    # Creates a new Player object.
    def initialize(map_id = 0)
      @map_id = map_id
      @x = 0
      @y = 0
      @direction = 2
      @speed = 2.2 # Has to be a float
      @graphic_name = "boy"
      @running = false
      @runcount = 0
    end

    def setup
      Visuals::Player.create(self)
    end

    # Changes the player's direction with a turn animation.
    # @param value [Integer, Symbol] the new direction.
    def direction=(value)
      value = validate_direction(value)
      $visuals.player.set_direction(value) unless @direction == value
      @direction = value
    end

    # Changes the player's direction without a turn animation.
    # @param value [Integer, Symbol] the new direction.
    def direction_noanim=(value)
      value = validate_direction(value)
      $visuals.player.set_direction_noanim(value) unless @direction == value
      @direction = value
    end

    # @return [Boolean] whether or not the player is currently moving.
    def moving?
      return $visuals.player.moving?
    end

    # @return [Boolean] whether or not the player is currently running.
    def running?
      return @running
    end

    # Fetches button input to move, trigger events, run, etc.
    def update
      unless moving?
        # Tile/event interaction
        if Input.confirm?
          newx, newy = facing_coordinates(@x, @y, @direction)
          $game.map.tile_interaction(newx, newy)
        end
        # Pause Menu
        if Input.trigger?(Input::START)
          PauseMenuUI.start
        end
      end
      @fake_move = false
      #@fake_move = true if $visuals.player.fake_anim
      oldrun = @running
      if Input.press?(Input::B)
        @runcount = 7 if !moving? && !@wasmoving && @runcount == 0
        @runcount += 1
      else
        @runcount = 0
      end
      @running = @runcount > 7 && moving?
      @speed = @running ? PLAYERRUNSPEED : PLAYERWALKSPEED
      if oldrun != @running # Walking to running or running to walking
        @graphic_name = @running ? "boy_run" : "boy"
      end
      if input_possible?
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

    # @return [Boolean] whether or not player input is possible. Used for pause menu, registered items and movement.
    def input_possible?
      return !moving? && !@wasmoving && !$game.any_events_running?
    end

    # Moves the player down one tile.
    private def move_down
      if @direction != 2 && @lastdir4 == 0 && !$visuals.player.fake_anim
        self.direction = :down
        @downcount = 8
      elsif @downcount.nil? || @downcount == 0 || @fake_move
        self.direction_noanim = :down if @direction != 2
        if $game.map.passable?(@x, @y + 1, :down, self)
          @y += 1
          try_transfer
          $game.map.check_event_triggers(true)
        else
          @fake_move = true
        end
        @downcount = nil
      end
      @downcount -= 1 if @downcount
    end

    # Moves the player down left tile.
    private def move_left
      if @direction != 4 && @lastdir4 == 0 && !$visuals.player.fake_anim
        self.direction = :left
        @leftcount = 8
      elsif @leftcount.nil? || @leftcount == 0 || @fake_move
        self.direction_noanim = :left if @direction != 4
        if $game.map.passable?(@x - 1, @y, :left, self)
          @x -= 1
          try_transfer
          $game.map.check_event_triggers(true)
        else
          @fake_move = true
        end
        @leftcount = nil
      end
      @leftcount -= 1 if @leftcount
    end

    # Moves the player down right tile.
    private def move_right
      if @direction != 6 && @lastdir4 == 0 && !$visuals.player.fake_anim
        self.direction = :right
        @rightcount = 8
      elsif @rightcount.nil? || @rightcount == 0 || @fake_move
        self.direction_noanim = :right if @direction != 6
        if $game.map.passable?(@x + 1, @y, :right, self)
          @x += 1
          try_transfer
          $game.map.check_event_triggers(true)
        else
          @fake_move = true
        end
        @rightcount = nil
      end
      @rightcount -= 1 if @rightcount
    end

    # Moves the player up one tile.
    private def move_up
      if @direction != 8 && @lastdir4 == 0 && !$visuals.player.fake_anim
        self.direction = :up
        @upcount = 8
      elsif @upcount.nil? || @upcount == 0 || @fake_move
        self.direction_noanim = :up if @direction != 8
        if $game.map.passable?(@x, @y - 1, :up, self)
          @y -= 1
          try_transfer
          $game.map.check_event_triggers(true)
        else
          @fake_move = true
        end
        @upcount = nil
      end
      @upcount -= 1 if @upcount
    end

    def global_x
      c = MKD::MapConnections.fetch(@map_id)
      return c ? c[1] + @x : @x
    end

    def global_y
      c = MKD::MapConnections.fetch(@map_id)
      return c ? c[2] + @y : @y
    end

    # Switches active map and position of the player if its x or y position are out of the current map.
    def try_transfer
      xsmall = @x < 0
      ysmall = @y < 0
      xgreat = @x >= $game.map.width
      ygreat = @y >= $game.map.height
      if xsmall || ysmall || xgreat || ygreat
        if $game.map.connection
          map_id, mapx, mapy = $game.get_map_from_connection($game.map, @x, @y)
          @map_id = map_id
          oldx = @x
          oldy = @y
          @x = mapx
          @y = mapy
          $visuals.map_renderer.adjust_to_player(oldx, oldy)
        else
          raise "Player is off the active game map, but no map connection was specified for that map."
        end
      end
    end

    def transfer(x, y, map_id = nil)
      xdiff = x - @x
      ydiff = y - @y
      if map_id == @map_id
        # Transfer on the same map
        @x = x
        @y = y
        $visuals.player.move(xdiff, ydiff, xdiff, ydiff)
      else
        # If the new map is already loaded into $game.maps, that means it's part of the connection
        # system of the current map and therefore doesn't need to be re-initialized or anything.
        if $game.maps[map_id]
          oldgx = $game.map.connection[1] + @x
          oldgy = $game.map.connection[2] + @y
          $game.player.map_id = map_id
          @x = x
          @y = y
          newgx = $game.map.connection[1] + x
          newgy = $game.map.connection[2] + y
          # xdiff & ydiff:
          # Difference in logical location (e.g. from (x,y) = (1, 1) to (34, 2) would be (33, 1))
          # newgx - oldgx & newgy - oldgy
          # Actual tile distance between old and new position.
          $visuals.player.move(xdiff, ydiff, newgx - oldgx, newgy - oldgy)
        else
          # Load new map with its own connection system.
        end
      end
    end

    attr_reader :fake_move
  end
end
