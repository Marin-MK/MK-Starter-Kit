class Game
  # Logic related to game switches.
  class Switches
    # Creates a new Switches object.
    def initialize
      @groups = [nil]
    end
    
    def get(group_id, switch_id)
      return @groups[group_id].get(switch_id)
    end
    alias [] get

    def set(group_id, switch_id, value)
      @groups[group_id].set(switch_id, value)
    end
    alias []= set
  end

  class SwitchGroup
    def get(id)
      return @switches[id] == true
    end

    def set(id, value)
      @switches[id] = value
    end
  end
end
