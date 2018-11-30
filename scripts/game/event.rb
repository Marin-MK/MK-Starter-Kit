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
    attr_accessor :moveroute_ignore_impassable

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
      @moveroute_ignore_impassable = false
      update
      Visuals::Map::Event.create(self)
    end

    def update
      for i in 0...@pages.size
        if all_conditions_true_on_page(i)
          if @current_page != @pages[i]
            # Switch event page
            @direction = @pages[i].graphic.direction
          end
          @current_page = @pages[i]
          break
        end
      end
    end

    def all_conditions_true_on_page(page_index)
      return !@pages[page_index].conditions.any? do |cond, params|
        !MKD::Event::SymbolToCondition[cond].new(self, params).valid?
      end
    end

    def trigger
      unless $game.map.event_interpreters.any? { |i| i.event == self }
        $game.map.event_interpreters << Interpreter.new(self, @current_page.commands)
      end
    end

    def move(*commands)
      commands = [commands] unless commands[0].is_a?(Array)
      commands.each do |e|
        @moveroute.concat(e)
      end
    end

    def moving?
      return @moveroute.size > 0
    end

    def moveroute_next
      $visuals.map.events[@id].moveroute_ready = true
      @moveroute.delete_at(0)
      case @moveroute[0]
      when :down, :left, :right, :up
        newx = @x
        newy = @y
        dir = validate_direction(@moveroute[0])
        newx -= 1 if [1, 4, 7].include?(dir)
        newx += 1 if [3, 6, 9].include?(dir)
        newy -= 1 if [7, 8, 9].include?(dir)
        newy += 1 if [1, 2, 3].include?(dir)
        if !$game.map.passable?(newx, newy, dir)
          if @moveroute_ignore_impassable
            moveroute_next
          else
            @moveroute.clear
          end
        end
      end
    end
  end
end