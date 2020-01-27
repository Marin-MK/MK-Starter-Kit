class Game
  # Logic related to event interpreters.
  class Interpreter
    # @return [Game::Event] the event related to the interpreter.
    attr_accessor :event
    # @return [Integer] the execution index of the command list.
    attr_accessor :index
    # @return [Boolean] whether or not the interpreter has to wait for any moveroutes to finish.
    attr_accessor :wait_for_move_completion
    # @return [Symbol] how this interpreter was triggered.
    attr_accessor :triggered_by

    # Creates a new Interpreter object.
    def initialize(event, commands, type, triggered_by)
      @event = event
      @commands = commands
      @index = 0
      @type = type
      @triggered_by = triggered_by
      @wait_for_move_completion = false
      @initial = true
      log(:OVERWORLD, "Event #{@event.id} triggered", true)
    end

    # @return [Boolean] whether or not the interpreter can run the next command.
    private def can_update?
      # Re-check the conditions in case they're no longer valid
      @event.test_pages
      if !@event.current_page || @commands != @event.current_page.commands
        @done = true
        dispose
        return false
      end
      # Wait if the event is moving
      if @event.moving? && @wait_for_move_completion
        return false
      else
        @wait_for_move_completion = false
      end
      if @index >= @commands.size
        if @type == :autorun
          restart
        else
          @done = true
          return false
        end
      end
      if @type == :event
        if $game.map.wait_count > 0 || $game.player.moving?
          return false
        end
      end
      return true
    end

    # Runs the next command if possible.
    def update
      return unless can_update?
      if @initial
        @event.turn_to_player
        @initial = false
        @event.triggered_by = @triggered_by
        return
      end
      indent, cmd, params = @commands[@index]
      case cmd
      when :if
        valid = execute_command(@index)
        # If the condition is true
        if valid
          @index += 1
        else # If the condition is false, find the else-statement or continue after the if-statement
          found = false
          for i in (@index + 1)...@commands.size
            if @commands[i][0] == indent
              found = true
              if @commands[i][1] == :else
                @index = i + 1
              else
                @index = i
              end
              break
            end
          end
          if !found
            @index = @commands.size
          end
        end
      when :else
        # When an if-statement is called and it's false, it skips :else
        # This means the only way this command can be :else is if it previously
        # ran a valid if-statement. So skip all commands in this else-statement.
        found = false
        for i in (@index + 1)...@commands.size
          if @commands[i][0] <= indent
            @index = i
            found = true
            break
          end
        end
        if !found
          @index = @commands.size
        end
      else # Any other command
        execute_command(@index)
        @index += 1
      end
    end

    # Restarts the interpreter.
    def restart
      @index = 0
      @done = false
    end

    # Runs a command.
    # @param index [Integer] the index of the command in the command list.
    def execute_command(index)
      command = @commands[index][1]
      params = @commands[index][2]
      if MKD::Event::SymbolToCommand.has_key?(command)
        MKD::Event::SymbolToCommand[command].new(@event, params).call
      else
        raise ArgumentError, "Could not find a command with identifier :#{command} in event ID #{@event.id}"
      end
    end

    # @return [Integer] whether the interpreter is done running commands.
    def done?
      return @done
    end

    # Disposes this interpreter if it's a Parallel Process.
    def dispose
      if @type == :parallel
        $game.map.parallel_interpreters.delete_if { |i| i == self }
      end
    end
  end
end
