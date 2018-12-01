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
      Visuals::Map::Event.create(self)
    end

    def update
      oldpage = @current_page
      @current_page = nil
      for i in 0...@pages.size
        if all_conditions_true_on_page(i)
          @current_page = @pages[i]
          if oldpage != @current_page
            # Run only if the page actually changed
            @direction = @current_page.graphic.direction
            if oldpage
              if oldpage.has_trigger?(:parallel_process)
                $game.map.parallel_interpreters.delete_if { |i| i.event == self }
              else
                $game.map.event_interpreters.delete_if { |i| i.event == self }
              end
            end
            if @current_page.has_trigger?(:parallel_process) || @current_page.has_trigger?(:autorun)
              trigger
            end
          end
          break
        end
      end
    end

    def all_conditions_true_on_page(page_index)
      return !@pages[page_index].conditions.any? do |cond, params|
        !MKD::Event::SymbolToCondition[cond].new(self, params).valid?
      end
    end

    def trigger(mode = :manual)
      if @current_page.has_trigger?(:parallel_process)
        $game.map.parallel_interpreters << Interpreter.new(self, @current_page.commands, :parallel, :parallel_process)
      elsif @current_page.has_trigger?(:autorun)
        autorun = Interpreter.new(self, @current_page.commands, :main, :autorun)
        autorun.update until autorun.done?
      else
        unless $game.map.event_interpreters.any? { |i| i.event == self }
          $game.map.event_interpreters << Interpreter.new(self, @current_page.commands, :event, mode)
        end
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

module MKD
  class Event
    class Page
      def has_trigger?(mode)
        return @triggers.any? { |e| e[0] == mode }
      end

      def trigger_argument(mode, key)
        if m = @triggers.find { |e| e[0] == mode }
          return m[1][key]
        end
        return nil
      end
    end
  end
end