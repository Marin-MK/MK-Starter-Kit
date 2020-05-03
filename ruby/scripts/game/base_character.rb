class Game
  # The base component of event/player objects.
  class BaseCharacter
    # @return [Integer] the ID of the map the character is currently on.
    attr_reader :map_id
    # @return [Integer] the x position of the character.
    attr_reader :x
    # @return [Integer] the y position of the character.
    attr_reader :y
    # @return [Integer] the direction the character is currently facing.
    attr_accessor :direction
    # @return [Float] how fast the character can move.
    attr_accessor :speed
    # @return [String] the name of the graphic the character currently has applied.
    attr_accessor :graphic_name
    # @return [Array<Symbol, Array>] an array of move commands that are to be executed.
    attr_accessor :moveroute
    # @return [Integer] the interval for updating the character's frame while walking.
    attr_accessor :frame_update_interval
    # @return [Boolean] whether to ignore impassable move commands.
    attr_accessor :moveroute_ignore_impassable
    # @return [Boolean] whether to animate while idling.
    attr_reader :idle_animation
    # @return [Integer] how fast the character animates while idling.
    attr_accessor :idle_speed
    # @return [Integer] how fast the character animates while walking
    attr_accessor :animation_speed

    def initialize(map_id, x = 0, y = 0, direction = 2, graphic_name = "", move_speed = PLAYERWALKSPEED, animation_speed = 16)
      @map_id = map_id
      @x = x
      @y = y
      @graphic_name = graphic_name
      @direction = direction
      @speed = move_speed
      @moveroute = []
      @moveroute_ignore_impassable = false
      @idle_animation = false
      @idle_speed = move_speed
      @animation_speed = animation_speed
      @wasmoving = false
      self.setup_visuals
    end

    def setup_visuals
      Visuals::BaseCharacter.create(self)
    end

    def visual
      return $b
    end

    def idle_animation=(value)
      @idle_animation = value
      # Ensure we don't end on a moving frame
      self.visual.finish_movement if !value && self.visual
    end

    # Turns the event to face the player.
    def turn_to_player
      diffx = @x - $game.player.x
      diffy = @y - $game.player.y
      down = diffy < 0
      left = diffx > 0
      right = diffx < 0
      up = diffy > 0
      if down
        @direction = 2
      elsif up
        @direction = 8
      elsif left
        @direction = 4
      elsif right
        @direction = 6
      end
    end

    def move_down
      self.visual.move_down
      @y += 1
      @direction = 2
    end

    def move_left
      self.visual.move_left
      @x -= 1
      @direction = 4
    end

    def move_right
      self.visual.move_right
      @x += 1
      @direction = 6
    end

    def move_up
      self.visual.move_up
      @y -= 1
      @direction = 8
    end

    # Performs a move route.
    # @param commands [Symbol, Array] list of move commands.
    def move(*commands)
      commands = [commands] unless commands[0].is_a?(Array)
      commands.each { |e| @moveroute.concat(e) }
    end

    # @return [Boolean] whether or not the character has an active move route.
    def moving?
      return true if @moveroute.size > 0
      return true if self.visual.moving? if self.visual
      return false
    end

    def was_moving?
      return @wasmoving
    end

    def moveroute_next
      @moveroute.delete_at(0)
      if @moveroute.size > 0
        command = @moveroute[0]
        command, args = command if command.is_a?(Array)
        command = [:down, :left, :right, :up].sample if command == :move_random
        command = [:turn_down, :turn_left, :turn_right, :turn_up].sample if command == :turn_random
        @moveroute[0] = args ? [command, args] : command
        if !move_command_possible?(@moveroute[0])
          # Makes sure the event doesn't get stuck on the moving frame.
          self.visual.finish_movement
          if @moveroute_ignore_impassable
            moveroute_next
          else
            @moveroute.clear
          end
        end
      else
        self.visual.finish_movement
      end
    end

    def pathfind(x, y)
      pathfinder = Pathfinder.new(self, @x, @y, x, y)
      while pathfinder.can_run?
        pathfinder.run
      end
      commands = []
      oldx = @x
      oldy = @y
      pathfinder.result.each do |r|
        if r.x > oldx
          commands << :right
        elsif r.x < oldx
          commands << :left
        elsif r.y > oldy
          commands << :down
        elsif r.y < oldy
          commands << :up
        end
        oldx = r.x
        oldy = r.y
      end
      self.move(commands)
    end

    # @param command [Symbol, Array] the move command to test.
    # @return [Boolean] whether or not the move command is executable.
    def move_command_possible?(command)
      validate command => [Symbol, Array]
      command, *args = command if command.is_a?(Array)
      case command
      when :down, :left, :right, :up
        dir = validate_direction(command)
        newx, newy = facing_coordinates(@x, @y, dir)
        return $game.map.passable?(newx, newy, dir, self)
      end
      return true
    end

    def update
      @wasmoving = moving?
    end
  end
end
