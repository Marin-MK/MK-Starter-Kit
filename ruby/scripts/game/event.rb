class Game
  # The logical component of event objects.
  class Event < BaseCharacter
    # @return [Integer] the ID of this event.
    attr_accessor :id

    # Creates a new Event object.
    def initialize(map_id, id)
      @map_id = map_id
      @id = id
      @current_page = nil
      @automoveroute_idx = 0
      @automove_wait = 0
      super(map_id, data.x, data.y, data.width, data.height, 2, "")
    end

    def setup_visuals
      Visuals::Event.create(self)
    end

    def visual
      return $visuals.maps[@map_id].events[@id]
    end

    def unload
      # TO-DO: Save position
    end

    def data
      return MKD::Map.fetch(@map_id).events[@id]
    end

    def width
      return data.width
    end

    def height
      return data.height
    end

    # @return [Array<Game::Event::Page>] an unchangeable list of possible active event pages.
    def pages
      return data.pages
    end

    # @return [Game::Event::Page, NilClass] the currently active page.
    def current_page
      return @current_page ? pages[@current_page] : nil
    end

    # Updates the event, but is only called once per frame.
    def update
      super
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
      oldpageindex = @current_page
      @current_page = nil
      for i in 0...pages.size
        if all_conditions_true?(pages.size - i - 1)
          @current_page = pages.size - i - 1
          if oldpageindex != @current_page
            oldpage = self.pages[oldpageindex] if !oldpageindex.nil?
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
            @speed = current_page.settings.move_speed
            # Use self.idle_animation= to call the method and ensure we're on a still frame, not a moving frame
            self.idle_animation = current_page.settings.idle_animation
            @idle_speed = current_page.settings.idle_speed
            @animation_speed = current_page.settings.move_speed * 64 # 0.25 * 64 => 16
          end
          break
        end
      end
    end

    # @param page_index [Integer] the index of the page to test the conditions of.
    # @return [Boolean] whether all the conditions on the page are true.
    def all_conditions_true?(page_index)
      return !pages[page_index].conditions.any? do |cond, params|
        next !MKD::Event::SymbolToCondition[cond].new(self, params).valid?
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
        unless $game.maps[@map_id].event_interpreters.any? { |i| i.event == self && !i.done? }
          $game.maps[@map_id].event_interpreters << Interpreter.new(self, current_page.commands, false, false)
        end
      end
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
        super()
        if @moveroute.size == 0
          if current_page.automoveroute.commands.size > 0
            moveroute_next(true)
          end
        end
      end
    end

    attr_accessor :automove_wait
  end
end
