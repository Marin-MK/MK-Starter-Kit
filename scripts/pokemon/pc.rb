class Trainer
  class PC
    INITIAL_BOXES = 14
    BOX_SIZE = 30

    attr_accessor :boxes
    attr_accessor :current_box

    def initialize
      @boxes = []
      @current_box = 0
      INITIAL_BOXES.times { |i| @boxes << Box.new("Box #{i + 1}") }
    end

    def [](key)
      return @boxes[key]
    end

    def full?
      return !@boxes.any? { |b| !b.full? }
    end

    def add_pokemon(poke)
      if self.full?
        return false
      elsif @boxes[@current_box].full?
        # Not sure if it tests starting at the next or the first - will try later.
      else
        return @boxes[@current_box].add_pokemon(poke)
      end
    end
  end
end

class Trainer
  class PC
    class Box
      attr_accessor :pokemon
      attr_accessor :name
      attr_accessor :wallpaper

      def initialize(name)
        @pokemon = [nil] * BOX_SIZE
        @name = name
        @wallpaper = nil
      end

      def [](key)
        return @pokemon[key]
      end

      def []=(key, value)
        @pokemon[key] = value
      end

      def full?
        return @pokemon.count { |e| !e.nil? } == BOX_SIZE
      end

      def add_pokemon(poke, index = nil)
        if index
          @pokemon[index] = poke
          return true
        else
          for i in 0...@pokemon.size
            unless @pokemon[i]
              @pokemon[i] = poke
              return true
            end
          end
        end
        return false
      end
    end
  end
end
