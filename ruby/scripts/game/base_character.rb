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
    # @return [Boolean] whether to wait for the pathfinder to find a valid path.
    attr_accessor :await_pathfinder

    def initialize(map_id, x = 0, y = 0, direction = 2, graphic_name = "", speed = PLAYERWALKSPEED, frame_update_interval = 16)
      @map_id = map_id
      @x = x
      @y = y
      @graphic_name = graphic_name
      @direction = direction
      @speed = speed
      @frame_update_interval = frame_update_interval
      @moveroute = []
      @moveroute_ignore_impassable = false
      @await_pathfinder = false
      self.setup_visuals
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
      return true if self.visual.moving?
      return false
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

    def pathfind(x, y, await_pathfinder)
      @await_pathfinder = await_pathfinder
      Thread.new do
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
        @await_pathfinder = false
      end
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
  end
end
