class Battle
  class Choice
    attr_accessor :value

    # Create a new choice object, used by UI controls
    # @param value [Integer] the choice made in the UI. Fight = 0, Bag = 1, Switch = 2, Run = 3.
    def initialize(value = nil)
      validate value => [NilClass, Integer]
      @value = value
    end

    # @return [Boolean] whether the choice was to fight.
    def fight?
      return @value == 0
    end

    # @return [Boolean] whether the choice was to open the bag.
    def bag?
      return @value == 1
    end

    # @return [Boolean] whether the choice was to open the party.
    def pokemon?
      return @value == 2
    end

    # @return [Boolean] whether the choice was to run.
    def run?
      return @value == 3
    end

    # @return [Boolean] whether the choice was to cancel.
    def cancel?
      return @value == -1
    end
  end
end
