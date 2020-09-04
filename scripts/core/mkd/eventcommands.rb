module MKD
  class Event
    # A Symbol -> Class table used to convert symbols to commands.
    SymbolToCommand = {}

    # Provides the basic template for all other commands.
    class BasicCommand < Serializable
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
    SymbolToCommand[:basic] = BasicCommand


    # Prints a message in a pop-up window.
    class DebugPrintCommand < BasicCommand
      def call
        msgbox @text
      end
    end
    SymbolToCommand[:debug_print] = DebugPrintCommand


    # Prints a message to the console.
    class ConsolePrintCommand < BasicCommand
      def call
        puts @text
      end
    end
    SymbolToCommand[:console_print] = ConsolePrintCommand


    # Evaluates code.
    class ScriptCommand < BasicCommand
      def call
        @event.instance_eval(@code)
      end
    end
    SymbolToCommand[:script] = ScriptCommand


    # Performs a move route.
    class MoveCommand < BasicCommand
      def call
        @event.move(@commands)
        @interpreter.wait_for_move_completion = @wait_for_move_completion
        @event.moveroute_ignore_impassable = @ignore_impassable
      end
    end
    SymbolToCommand[:move] = MoveCommand


    # If-statement.
    class IfCommand < BasicCommand
      def call
        valid = MKD::Event::SymbolToCondition[@condition[0]].new(@event, @condition[1]).valid?
        return valid
      end
    end
    SymbolToCommand[:if] = IfCommand


    # Changes the value of a Game Switch.
    class SetSwitchCommand < BasicCommand
      def call
        # First treat as setting equal to
        if @value.is_a?(Boolean)
          $game.switches[@group_id, @switch_id] = @value
        elsif @value.is_a?(String)
          $game.switches[@group_id, @switch_id] = !!@event.instance_eval(@value)
        elsif @value.is_a?(Hash)
          $game.switches[@group_id, @switch_id] = $game.switches[@group_id, @switch_id]
        end
        # If it's actually opposite, then just invert the value now
        if @operator == :opposite
          $game.switches[@group_id, @switch_id] = !$game.switches[@group_id, @switch_id]
        end
      end
    end
    SymbolToCommand[:set_switch] = SetSwitchCommand


    # Changes the value of a Game Variable.
    class SetVariableCommand < BasicCommand
      def call
        $game.variables[@group_id, @variable_id] = @value
      end
    end
    SymbolToCommand[:set_variable] = SetVariableCommand


    # Waits a certain number of frames.
    class WaitCommand < BasicCommand
      def call
        $game.maps.each_value { |e| e.wait_count += @frames }
      end
    end
    SymbolToCommand[:wait] = WaitCommand


    # Triggers another event.
    class CallEventCommand < BasicCommand
      def call
        $game.maps[@map_id].events[@event_id].trigger(:event)
      end
    end
    SymbolToCommand[:call_event] = CallEventCommand


    class TransferPlayerCommand < BasicCommand
      def call
        $game.player.transfer(@x, @y, @map_id)
      end
    end
    SymbolToCommand[:transfer_player] = TransferPlayerCommand


    class MessageCommand < BasicCommand
      def call
        show_message(@text)
      end
    end
    SymbolToCommand[:message] = MessageCommand


    class PathfindCommand < BasicCommand
      def call
        object = @player ? $game.player : @event
        object.pathfind(@x, @y)
        @interpreter.wait_for_move_completion = @wait_for_move_completion
      end
    end
    SymbolToCommand[:pathfind] = PathfindCommand


  end
end
