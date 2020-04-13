class Game
  # Logic related to game variables.
  class Variables
    # Creates a new Variables object.
    def initialize
      @groups = [nil]
    end

    def get(group_id, var_id)
      return @groups[group_id].get(var_id)
    end
    alias [] get

    def set(group_id, var_id, value)
      @groups[group_id].set(var_id, value)
    end
    alias []= set
  end

  class VariableGroup
    def get(id)
      return @variables[id]
    end

    def set(id, value)
      @variables[id] = value
    end
  end
end
