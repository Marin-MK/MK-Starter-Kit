module MKD
  class Event
    # A Symbol -> Class table used to convert symbols to conditions.
    SymbolToCondition = {}

    # Provides the basic template for all other conditions.
    class BasicCondition < Serializable
      def initialize(event, hash)
        @event = event
        hash ||= {}
        # Effectively turns {text: "This is text"} into @text = "This is text", for example
        hash.keys.each { |e| instance_variable_set("@#{e}", hash[e]) }
      end

      def valid?
        return true
      end
    end
    SymbolToCondition[:basic] = BasicCondition


    # Tests a Game Switch for a value.
    class SwitchCondition < BasicCondition
      def valid?
        return $game.switches[@group_id, @switch_id] == @value
      end
    end
    SymbolToCondition[:switch] = BasicCondition


    # Tests a Game Variable for a value.
    class VariableCondition < BasicCondition
      def valid?
        return $game.variables[@group_id, @variable_id] == @value
      end
    end
    SymbolToCondition[:variable] = BasicCondition


    # Tests the return value of code that is evaluated.
    class ScriptCondition < BasicCondition
      def valid?
        return @event.instance_eval(@code)
      end
    end
    SymbolToCondition[:script] = ScriptCondition

    
  end
end
