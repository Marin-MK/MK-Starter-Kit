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


    SymbolToCommand = {
      basic: BasicCommand,
      debug_print: DebugPrintCommand,
      console_print: ConsolePrintCommand,
      script: ScriptCommand,
    }
  end
end