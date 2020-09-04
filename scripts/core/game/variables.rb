class Game
  # Logic related to game variables.
  class Variables
    def initialize
      @groups = [nil]
    end

    def get(group_id, var_id)
      return nil if @groups[group_id].nil?
      return @groups[group_id][var_id]
    end
    alias [] get

    def set(group_id, var_id, value)
      @groups[group_id] ||= {}
      @groups[group_id][var_id] = value
    end
    alias []= set
  end
end
