class Interpreter
  attr_accessor :event
  attr_accessor :index
  attr_accessor :wait_for_move_completion

  def initialize(event, commands)
    @event = event
    @commands = commands
    @index = 0
    @wait_for_move_completion = false
  end

  def update
    if @event.moving? && @wait_for_move_completion
      return
    else
      @wait_for_move_completion = false
    end
    if @index >= @commands.size
      @done = true
      return
    end
    if $game.map.wait_count > 0 || $game.player.moving?
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

  def execute_command(index)
    command = @commands[index][1]
    params = @commands[index][2]
    MKD::Event::SymbolToCommand[command].new(@event, params).call
  end

  def done?
    return @done
  end
end