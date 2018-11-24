module MKD
  class Event
    class BasicCommand
      def initialize(event, hash)
        @event = event
        hash ||= {}
        # Effectively turns {text: "This is text"} into @text = "This is text", for example
        hash.keys.each { |e| instance_variable_set("@#{e}", hash[e]) }
      end

      def call
      end
    end


    class DebugPrintCommand < BasicCommand
      def call
        p @text
      end
    end


    class ConsolePrintCommand < BasicCommand
      def call
        puts @text
      end
    end


    class ScriptCommand < BasicCommand
      def call
        @event.instance_eval(@code)
      end
    end


    class MoveCommand < BasicCommand
      def call
        @event.move(@commands)
      end
    end


    class IfCommand < BasicCommand
      def call
        valid = MKD::Event::SymbolToCondition[@condition[0]].new(@event, @condition[1]).valid?
        cmds = (valid ? @true : @false)
        if cmds
          cmds.each do |cmd, params|
            MKD::Event::SymbolToCommand[cmd].new(@event, params).call
          end
        end
      end
    end


    class SetSwitchCommand < BasicCommand
      def call
        $game.switches[@switchid] = @value
      end
    end


    class WaitCommand < BasicCommand
      def call
        # About to implement
      end
    end


    SymbolToCommand = {
      basic: BasicCommand,
      debug_print: DebugPrintCommand,
      console_print: ConsolePrintCommand,
      script: ScriptCommand,
      move: MoveCommand,
      if: IfCommand,
      setswitch: SetSwitchCommand,
      wait: WaitCommand,
    }
  end
end