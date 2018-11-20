class Game
  class Event
    attr_accessor :map_id
    attr_accessor :id
    attr_accessor :x
    attr_accessor :y
    attr_accessor :states
    attr_accessor :active_state
    attr_accessor :settings
    attr_accessor :moveroute
    attr_accessor :speed
    attr_accessor :direction

    def initialize(map_id, id, data)
      @map_id = map_id
      @id = id
      @data = data
      @x = @data.x
      @y = @data.y
      @states = @data.states
      @settings = @data.settings
      @active_state = nil
      @moveroute = []
      @speed = 2.2
      @direction = nil
      update
      Visuals::Map::Event.create(self)
    end

    def update
      for i in 0...@states.size
        unless @states[i].conditions.any? { |e| !MKD::Event::SymbolToCondition[e[0]].new(self, e[1]).valid? }
          if @active_state != @states[i]
            @direction = @states[i].graphic.direction
            # Switch event states
          end
          @active_state = @states[i]
          break
        end
      end
    end

    def trigger
      @active_state.commands.each do |e|
        MKD::Event::SymbolToCommand[e[0]].new(self, e[1]).call
      end
    end

    def move(*args)
      args.each do |e|
        @moveroute.concat(e)
      end
    end
  end
end