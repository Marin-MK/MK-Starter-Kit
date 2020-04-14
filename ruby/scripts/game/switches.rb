class Game
  # Logic related to game switches.
  class Switches
    def initialize
      @groups = [nil]
    end

    def get(group_id, switch_id)
      return @groups[group_id][switch_id]
    end
    alias [] get

    def set(group_id, switch_id, value)
      if @groups[group_id].nil?
        raise "No group with id '#{group_id}' found."
      end
      @groups[group_id][switch_id] = value
    end
    alias []= set
  end
end
