class Game
  # Logic related to game variables.
  class Variables
    # Creates a new Variables object.
    def initialize
      @values = []
    end

    # Fetches the value of the game variable with the specified ID.
    # @param id [Integer] the ID of the variable to fetch.
    # @return [Object] the value of the variable.
    def get(id)
      validate id => Integer
      return @values[id]
    end
    alias [] get

    # Sets the value of the game variable with the specified ID.
    # @param id [Integer] the ID of the variable to set.
    # @param value [Object] the new value for the variable.
    def set(id, value)
      validate id => Integer
      @values[id] = value
    end
    alias []= set
  end
end
