class Game
  # Logic related to game switches.
  class Switches
    def initialize
      @groups = [nil]
    end

    def get(group_id, switch_id)
      return false if @groups[group_id].nil?
      return @groups[group_id][switch_id] == true
    end
    alias [] get

    def set(group_id, switch_id, value)
      @groups[group_id] ||= {}
      @groups[group_id][switch_id] = value
    end
    alias []= set
  end
end
