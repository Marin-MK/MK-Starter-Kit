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
        raise "BasicCondition#valid? called! A condition superclass has failed to define the #valid? method!"
      end
    end
    SymbolToCondition[:basic] = BasicCondition


    # Tests a Game Switch for a value.
    class SwitchCondition < BasicCondition
      def valid?
        return $game.switches[@group_id, @switch_id] == @value
      end
    end
    SymbolToCondition[:switch] = SwitchCondition


    # Tests a Game Variable for a value.
    class VariableCondition < BasicCondition
      def valid?
        var = $game.variables[@group_id, @variable_id]
        if @value.is_a?(Hash)
          value = $game.variables[@value[:group_id], @value[:variable_id]]
        elsif @value.is_a?(String)
          value = @event.instance_eval { @value }
        else
          value = @value
        end
        case @operator
        when :empty
          return var.nil?
        when :equal
          return var == value
        else
          raise "Condition script value ('#{@value}') must return an integer!" if !value.is_a?(Numeric) && @value.is_a?(String)
          if !var.is_a?(Numeric)
            # The left-hand Game Variable is nil, so it's always false.
            return false
          end
          if !value.is_a?(Numeric) && @value.is_a?(Hash)
            # The right-hand Game Variable is nil, so it's always false.
            return false
          end
          case @operator
          when :greater
            return var > value
          when :less
            return var < value
          when :greaterequal
            return var >= value
          when :lessequal
            return var <= value
          else
            raise "Unkown Game Variable comparison operator: #{@operator}"
          end
        end
      end
    end
    SymbolToCondition[:variable] = VariableCondition


    # Tests the return value of code that is evaluated.
    class ScriptCondition < BasicCondition
      def valid?
        return !!@event.instance_eval(@code)
      end
    end
    SymbolToCondition[:script] = ScriptCondition


  end
end
