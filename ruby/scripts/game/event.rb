class Game
  # The logical component of event objects.
  class Event
    # @return [Integer] the ID of the map this event is on.
    attr_accessor :map_id
    # @return [Integer] the ID of this event.
    attr_accessor :id
    # @return [Integer] the x position of this event.
    attr_reader :x
    # @return [Integer] the y position of this event.
    attr_reader :y
    # @return [Array<Symbol, Array>] an array of move commands that are to be executed.
    attr_accessor :moveroute
    # @return [Float] how fast the event moves.
    attr_accessor :speed
    # @return [Integer] which direction the event is currently facing.
    attr_accessor :direction

    # Creates a new Event object.
    def initialize(map_id, id)
      @map_id = map_id
      @id = id
      @x = data.x
      @y = data.y
      @current_page = nil
      @moveroute = []
      @speed = settings.speed
      @direction = 2
      @moveroute_ignore_impassable = false
      @automoveroute_idx = 0
      @automove_wait = 0
      @await_pathfinder = false
      setup_visuals
    end

    def setup_visuals
      Visuals::Event.create(self)
    end

    def unload
      # TO-DO: Save position
    end

    def data
      return MKD::Map.fetch(@map_id).events[@id]
    end

    # @return [Array<Game::Event::Page>] an unchangeable list of possible active event pages.
    def pages
      return data.pages
    end

    # @return [Game::Event::Page, NilClass] the currently active page.
    def current_page
      return @current_page ? pages[@current_page] : nil
    end

    # @return [Game::Event::Settings] configurable settings that change this event's behaviour.
    def settings
      return data.settings
    end

    # Updates the event, but is only called once per frame.
    def update
      test_pages
      if current_page && current_page.automoveroute.commands.size > 0
        run = true
        run = false if $game.map.event_interpreters.any? { |i| i.event == self }
        run = false if moving?
        run = false if !$visuals.maps[@map_id].events[@id].moveroute_ready
        if run
          if @automove_wait > 0
            @automove_wait -= 1
          else
            start_idx = @automoveroute_idx
            command = current_page.automoveroute.commands[@automoveroute_idx]
            command, args = command if command.is_a?(Array)
            command = [:down, :left, :right, :up].sample if command == :move_random
            command = [:turn_down, :turn_left, :turn_right, :turn_up].sample if command == :turn_random
            command = [command, args] if args
            @automoveroute_idx += 1
            @automoveroute_idx = 0 if @automoveroute_idx >= current_page.automoveroute.commands.size
            if move_command_possible?(command)
              $visuals.maps[@map_id].events[@id].automoveroute(command)
            else
              # If the movement cannot be executed, at least turn in that direction.
              if command == :down || command == :left || command == :right || command == :up
                $visuals.maps[@map_id].events[@id].automoveroute(command.to_s.prepend("turn_").to_sym)
              end
              # Reset index to try again next frame
              @automoveroute_idx = start_idx
              # Makes sure the event doesn't get stuck on a moving frame
              $visuals.maps[@map_id].events[@id].finish_movement
            end
          end
        end
      end
    end

    # Re-evaluates the conditions on each page and changes the page if necessary.
    def test_pages
      oldpage = @current_page
      @current_page = nil
      for i in 0...pages.size
        if all_conditions_true?(i)
          @current_page = i
          if oldpage != @current_page
            # Run only if the page actually changed
            @direction = current_page.graphic.direction || 2
            # Delete any interpreters there may be left trying to run the old page
            if oldpage
              if oldpage.trigger_mode == :parallel_process
                $game.map.parallel_interpreters.delete_if { |i| i.event == self }
              else
                $game.map.event_interpreters.delete_if { |i| i.event == self }
              end
            end
            # Execute event if new page is Parallel Process or Autorun
            if current_page.trigger_mode == :parallel_process || current_page.trigger_mode == :autorun
              trigger
            end
            if current_page.automoveroute.commands.size > 0
              # Wait 1 frame to start the new autonomous move route so the visuals have time to adjust to the new page.
              @automove_wait = 1
            end
          end
          break
        end
      end
    end

    def move_down
      $visuals.maps[@map_id].events[@id].move_down
      @y += 1
      @direction = 2
    end

    def move_left
      $visuals.maps[@map_id].events[@id].move_left
      @x -= 1
      @direction = 4
    end

    def move_right
      $visuals.maps[@map_id].events[@id].move_right
      @x += 1
      @direction = 6
    end

    def move_up
      $visuals.maps[@map_id].events[@id].move_up
      @y -= 1
      @direction = 8
    end

    # @param page_index [Integer] the index of the page to test the conditions of.
    # @return [Boolean] whether all the conditions on the page are true.
    def all_conditions_true?(page_index)
      return !pages[page_index].conditions.any? do |cond, params|
        !MKD::Event::SymbolToCondition[cond].new(self, params).valid?
      end
    end

    # Executes the event.
    # @param mode [NilClass, Symbol] how the event was triggered.
    def trigger
      if current_page.trigger_mode == :parallel_process
        $game.maps[@map_id].parallel_interpreters << Interpreter.new(self, current_page.commands, false, true)
      elsif current_page.trigger_mode == :autorun
        autorun = Interpreter.new(self, current_page.commands, true, false)
        autorun.update until autorun.done?
      else
        unless $game.maps[@map_id].event_interpreters.any? { |i| i.event == self }
          $game.maps[@map_id].event_interpreters << Interpreter.new(self, current_page.commands, false, false)
        end
      end
    end

    # Performs a move route.
    # @param commands [Symbol, Array] list of move commands.
    def move(*commands)
      commands = [commands] unless commands[0].is_a?(Array)
      commands.each { |e| @moveroute.concat(e) }
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

    # @return [Boolean] whether or not the event has an active move route.
    def moving?
      return true if @moveroute.size > 0
      return true if $visuals.maps[@map_id].events[@id].moving?
      return false
    end

    # Executes the next move command in the moveroute, if present.
    # @param automoveroute [Boolean] whether or not the previous move command was from an autonomous move route.
    def moveroute_next(automoveroute = false)
      newx, newy = facing_coordinates(@x, @y, @direction)
      if $game.player.x == newx && $game.player.y == newy && current_page && current_page.trigger_mode == :event_touch
        trigger(:event_touch)
        @moveroute.clear if !automoveroute
      elsif automoveroute # Next move command for an Autonomous Move Route
        # Apply a wait until the next auto move command
        @automove_wait = [1, (Graphics.frame_rate * current_page.automoveroute.frequency).round].max
      else # Next move command for a normal moveroute
        @moveroute.delete_at(0)
        if @moveroute.size > 0
          command = @moveroute[0]
          command, args = command if command.is_a?(Array)
          command = [:down, :left, :right, :up].sample if command == :move_random
          command = [:turn_down, :turn_left, :turn_right, :turn_up].sample if command == :turn_random
          @moveroute[0] = args ? [command, args] : command
          if !move_command_possible?(@moveroute[0])
            # Makes sure the event doesn't get stuck on the moving frame.
            $visuals.maps[@map_id].events[@id].finish_movement
            if @moveroute_ignore_impassable
              moveroute_next
            else
              @moveroute.clear
            end
          end
        else
          $visuals.maps[@map_id].events[@id].finish_movement
          if current_page.automoveroute.commands.size > 0
            moveroute_next(true)
          end
        end
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

    attr_accessor :moveroute_ignore_impassable
    attr_accessor :automove_wait
    attr_accessor :await_pathfinder
  end
end
