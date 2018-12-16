module MKD
  class Event
    # Provides the basic template for all other commands.
    class BasicCommand
      def initialize(event, hash)
        @event = event
        hash ||= {}
        # Effectively turns {text: "This is text"} into @text = "This is text", for example
        hash.keys.each { |e| instance_variable_set("@#{e}", hash[e]) }
        @interpreter = $game.map.event_interpreters.find { |i| i.event == @event }
      end

      def call
      end
    end

    # Prints a message in a pop-up window.
    class DebugPrintCommand < BasicCommand
      def call
        msgbox @text
      end
    end

    # Prints a message to the console.
    class ConsolePrintCommand < BasicCommand
      def call
        puts @text
      end
    end

    # Evaluates code.
    class ScriptCommand < BasicCommand
      def call
        @event.instance_eval(@code)
      end
    end

    # Performs a move route.
    class MoveCommand < BasicCommand
      def call
        @event.move(@commands)
        @interpreter.wait_for_move_completion = @wait_for_completion
        @event.moveroute_ignore_impassable = @ignore_impassable
      end
    end

    # If-statement.
    class IfCommand < BasicCommand
      def call
        valid = MKD::Event::SymbolToCondition[@condition[0]].new(@event, @condition[1]).valid?
        return valid
      end
    end

    # Changes the value of a Game Switch.
    class SetSwitchCommand < BasicCommand
      def call
        if @value == :inverted
          $game.switches[@switchid] = !$game.switches[@switchid]
        else
          $game.switches[@switchid] = @value
        end
      end
    end

    # Changes the value of a Game Variable.
    class SetVariableCommand < BasicCommand
      def call
        $game.variables[@variableid] = @value
      end
    end

    # Waits a certain number of frames.
    class WaitCommand < BasicCommand
      def call
        $game.map.wait_count += @frames
      end
    end

    # Triggers another event.
    class CallEventCommand < BasicCommand
      def call
        $game.map.events[@eventid].trigger(:event)
      end
    end


    class TransferCommand < BasicCommand
      def call
        xdiff = @x - $game.player.x
        ydiff = @y - $game.player.y
        if @mapid == $game.player.map_id
          # Transfer on the same map
          $game.player.x = @x
          $game.player.y = @y
          $visuals.player.move(xdiff, ydiff)
        else
          # If it's loaded into $game.maps, that means it's part of the connection
          # system of the current map (meaning it's been loaded already)
          if $game.maps[@mapid]
            oldgx = $game.map.connection[1] + $game.player.x
            oldgy = $game.map.connection[2] + $game.player.y
            $game.player.map_id = @mapid
            $game.player.x = @x
            $game.player.y = @y
            newgx = $game.map.connection[1] + @x
            newgy = $game.map.connection[2] + @y
            $visuals.player.move(xdiff, ydiff, newgx - oldgx, newgy - oldgy)
          else

          end
        end
      end
    end


    # A Symbol -> Class table used to convert symbols to commands.
    SymbolToCommand = {
      basic: BasicCommand,
      debug_print: DebugPrintCommand,
      console_print: ConsolePrintCommand,
      script: ScriptCommand,
      move: MoveCommand,
      if: IfCommand,
      setswitch: SetSwitchCommand,
      setvariable: SetVariableCommand,
      wait: WaitCommand,
      call_event: CallEventCommand,
      transfer: TransferCommand
    }
  end
end
