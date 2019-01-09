class Game
  # Logic related to game switches.
  class Switches
    # Creates a new Switches object.
    def initialize
      @values = []
    end

    # Fetches the value of the game switch with the specified ID.
    # @param id [Integer] the ID of the switch to fetch.
    # @return [Boolean] the value of the switch.
    def get(id)
      validate id => Integer
      return @values[id] == true
    end
    alias [] get

    # Sets the value of the game switch with the specified ID.
    # @param id [Integer] the ID of the switch to set.
    # @param value [Boolean] the new value for the switch.
    def set(id, value)
      validate id => Integer, value => [FalseClass, TrueClass]
      @values[id] = value
    end
    alias []= set
  end
end
