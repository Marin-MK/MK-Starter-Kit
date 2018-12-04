class Game
  class Interpreter
    attr_accessor :event
    attr_accessor :index
    attr_accessor :wait_for_move_completion
    attr_accessor :triggered_by

    def initialize(event, commands, type, triggered_by)
      @event = event
      @commands = commands
      @index = 0
      @type = type
      @triggered_by = triggered_by
      @wait_for_move_completion = false
    end

    private def can_update?
      @event.update
      if !@event.current_page || @commands != @event.current_page.commands
        @done = true
        dispose
        return
      end
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

    def update
      @event.triggered_by = @triggered_by
      return unless can_update?
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

    def restart
      @index = 0
      @done = false
    end

    def execute_command(index)
      command = @commands[index][1]
      params = @commands[index][2]
      if MKD::Event::SymbolToCommand.has_key?(command)
        MKD::Event::SymbolToCommand[command].new(@event, params).call
      else
        raise ArgumentError, "Could not find a command with identifier :#{command} in event ID #{@event.id}"
      end
    end

    def done?
      return @done
    end

    def dispose
      if @type == :parallel
        $game.map.parallel_interpreters.delete_if { |i| i == self }
      end
    end
  end
end