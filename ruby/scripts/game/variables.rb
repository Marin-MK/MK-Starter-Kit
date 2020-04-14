class Game
  # Logic related to game variables.
  class Variables
    def initialize
      @groups = [nil]
    end

    def get(group_id, var_id)
      return @groups[group_id][var_id]
    end
    alias [] get

    def set(group_id, var_id, value)
      if @groups[group_id].nil?
        raise "No group with id '#{group_id}' found."
      end
      @groups[group_id][var_id] = value
    end
    alias []= set
  end
end
