class Game
  # The logical component of event objects.
  class Event
    # @return [Fixnum] the ID of the map this event is on.
    attr_accessor :map_id
    # @return [Fixnum] the ID of this event.
    attr_accessor :id
    # @return [Fixnum] the x position of this event.
    attr_accessor :x
    # @return [Fixnum] the y position of this event.
    attr_accessor :y
    # @return [Array<Game::Event::Page>] an unchangeable list of possible active event pages.
    attr_accessor :pages
    # @return [Game::Event::Page, NilClass] the currently active page.
    attr_accessor :current_page
    # @return [Game::Event::Settings] configurable settings that change this event's behaviour.
    attr_accessor :settings
    # @return [Array<Symbol, Array>] an array of move commands that are to be executed.
    attr_accessor :moveroute
    # @return [Float] how fast the event moves.
    attr_accessor :speed
    # @return [Fixnum] which direction the event is currently facing.
    attr_accessor :direction

    # Creates a new Event object.
    def initialize(map_id, id, data)
      @map_id = map_id
      @id = id
      @data = data
      @x = @data.x
      @y = @data.y
      @pages = @data.pages
      @settings = @data.settings
      @current_page = nil
      @moveroute = []
      @speed = @settings.speed
      @direction = 2
      @moveroute_ignore_impassable = false
      @automoveroute_idx = 0
      @automove_wait = 0
      Visuals::Event.create(self)
    end

    # Updates the event, but is only called once per frame.
    def update
      test_pages
      if @current_page && @current_page.automoveroute[:commands].size > 0
        run = true
        run = false if $game.map.event_interpreters.any? { |i| i.event == self }
        run = false if moving?
        run = false if !$visuals.maps[@map_id].events[@id].moveroute_ready
        if run
          if @automove_wait > 0
            @automove_wait -= 1
          else
            start_idx = @automoveroute_idx
            @automoveroute_idx += 1
            @automoveroute_idx = 0 if @automoveroute_idx >= @current_page.automoveroute[:commands].size
            command = @current_page.automoveroute[:commands][@automoveroute_idx]
            if move_command_possible?(command)
              $visuals.maps[@map_id].events[@id].automoveroute(command)
            else
              # Reset index to try again next frame
              @automoveroute_idx = start_idx
            end
          end
        end
      end
    end

    # Re-evaluates the conditions on each page and changes the page if necessary.
    def test_pages
      oldpage = @current_page
      @current_page = nil
      for i in 0...@pages.size
        if all_conditions_true_on_page(i)
          @current_page = @pages[i]
          if oldpage != @current_page
            # Run only if the page actually changed
            @direction = @current_page.graphic[:direction] || 2
            # Delete any interpreters there may be left trying to run the old page
            if oldpage
              if oldpage.has_trigger?(:parallel_process)
                $game.map.parallel_interpreters.delete_if { |i| i.event == self }
              else
                $game.map.event_interpreters.delete_if { |i| i.event == self }
              end
            end
            # Execute event if new page is Parallel Process or Autorun
            if @current_page.has_trigger?(:parallel_process) || @current_page.has_trigger?(:autorun)
              trigger
            end
            if @current_page.automoveroute[:commands].size > 0
              # Wait 1 frame to start the new autonomous move route so the visuals have time to adjust to the new page.
              @automove_wait = 1
            end
          end
          break
        end
      end
    end

    # @param page_index [Fixnum] the index of the page to test the conditions of.
    # @return [Boolean] whether all the conditions on the page are true.
    def all_conditions_true_on_page(page_index)
      return !@pages[page_index].conditions.any? do |cond, params|
        !MKD::Event::SymbolToCondition[cond].new(self, params).valid?
      end
    end

    # Executes the event.
    # @param mode [NilClass, Symbol] how the event was triggered.
    def trigger(mode = :manual)
      if @current_page.has_trigger?(:parallel_process)
        $game.map.parallel_interpreters << Interpreter.new(self, @current_page.commands, :parallel, :parallel_process)
      elsif @current_page.has_trigger?(:autorun)
        autorun = Interpreter.new(self, @current_page.commands, :main, :autorun)
        autorun.update until autorun.done?
      else
        unless $game.map.event_interpreters.any? { |i| i.event == self }
          $game.map.event_interpreters << Interpreter.new(self, @current_page.commands, :event, mode)
        end
      end
    end

    # Performs a move route.
    # @param commands [Symbol, Array] list of move commands.
    def move(*commands)
      commands = [commands] unless commands[0].is_a?(Array)
      commands.each do |e|
        @moveroute.concat(e)
      end
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
      if $game.player.x == newx && $game.player.y == newy && @current_page && @current_page.has_trigger?(:event_touch)
        trigger(:event_touch)
        @moveroute.clear if !automoveroute
      elsif automoveroute # Next move command for an Autonomous Move Route
        # Apply a wait until the next auto move command
        @automove_wait = @current_page.automoveroute[:frequency]
      else # Next move command for a normal moveroute
        @moveroute.delete_at(0)
        if @moveroute.size > 0
          if !move_command_possible?(@moveroute[0])
            if @moveroute_ignore_impassable
              moveroute_next
            else
              @moveroute.clear
            end
          end
        else
          if @current_page.automoveroute[:commands].size > 0
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

    attr_accessor :moveroute_ignore_impassable
    attr_accessor :triggered_by
    attr_accessor :automove_wait
  end
end

module MKD
  class Event
    class Page
      # @param mode [Symbol] the trigger mode to look for.
      # @return [Boolean] whether the page can be triggered by the mode specified.
      def has_trigger?(mode)
        return @triggers.any? { |e| e[0] == mode }
      end

      # @param mode [Symbol] the trigger mode to look for.
      # @param key [Symbol] the key in the parameter hash to look for.
      # @return [Object, NilClass] the parameter specified.
      def trigger_argument(mode, key)
        if m = @triggers.find { |e| e[0] == mode }
          return m[1][key]
        end
        return nil
      end
    end
  end
end
