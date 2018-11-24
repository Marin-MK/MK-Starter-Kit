class Game
  class Event
    attr_accessor :map_id
    attr_accessor :id
    attr_accessor :x
    attr_accessor :y
    attr_accessor :pages
    attr_accessor :current_page
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
      @pages = @data.pages
      @settings = @data.settings
      @current_page = nil
      @moveroute = []
      @speed = 2.2
      @direction = nil
      update
      Visuals::Map::Event.create(self)
    end

    def update
      for i in 0...@pages.size
        unless @pages[i].conditions.any? { |cond, params| !MKD::Event::SymbolToCondition[cond].new(self, params).valid? }
          if @current_page != @pages[i]
            # Switch event page
            @direction = @pages[i].graphic.direction
          end
          @current_page = @pages[i]
          break
        end
      end
    end

    def trigger
      @current_page.commands.each do |cmd, params|
        MKD::Event::SymbolToCommand[cmd].new(self, params).call
      end
    end

    def move(*commands)
      commands = [commands] unless commands[0].is_a?(Array)
      commands.each do |e|
        @moveroute.concat(e)
      end
    end
  end
end