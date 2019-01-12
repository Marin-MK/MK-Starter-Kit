class Trainer
  # The trainer's PC. Stores items and Pokemon.
  class PC
    # @return [Integer] How many boxes a new trainer starts with.
    INITIAL_BOXES = 14
    # @return [Integer] How many Pokemon a Box in the PC can store.
    BOX_SIZE = 30

    # @return [Array<Box>] the array of boxes that store Pokemon.
    attr_accessor :boxes
    # @return [Integer] the index of the current box.
    attr_accessor :current_box
    # @return [Array<Hash>] the list of items that are currently in the PC.
    attr_accessor :items

    # Creates a new PC object.
    def initialize
      @boxes = []
      @current_box = 0
      @items = [{item: :POTION, count: 1}]
      INITIAL_BOXES.times { |i| @boxes << Box.new("BOX#{i + 1}") }
    end

    def [](key)
      return @boxes[key]
    end

    # @return [Boolean] whether or not the PC is full.
    def full?
      return !@boxes.any? { |b| !b.full? }
    end

    # Adds the Pokemon to the current box, or the next box if it's full.
    # @param poke [Pokemon] the Pokemon to add to the storage system.
    # @return [Boolean] whether or not the Pokemon could be added.
    def add_pokemon(poke)
      if self.full?
        return false
      elsif @boxes[@current_box].full?
        idx = @current_box + 1
        loop do
          if @boxes[idx].full?
            idx += 1
            idx = 0 if idx >= @boxes.size
            if idx == @current_box
              # Back to starting box, means PC is full
              # Should not be possible to get to this point
              # because of the self.full? check above
              return false
            end
          else
            @boxes[idx].add_pokemon(poke)
            return true
          end
        end
      else
        return @boxes[@current_box].add_pokemon(poke)
      end
    end
  end
end

class Trainer
  class PC
    class Box
      # @return [Array<Pokemon, NilClass>] the array of Pokemon in this box.
      attr_accessor :slots
      # @return [String] the name of this box.
      attr_accessor :name
      # @return [Integer] the ID of the wallpaper this box has.
      attr_accessor :wallpaper

      def initialize(name)
        @slots = [nil] * BOX_SIZE
        @name = name
        @wallpaper = 0
      end

      def [](key)
        return @slots[key]
      end

      def []=(key, value)
        @slots[key] = value
      end

      # @return [Boolean] whether or not this box is full.
      def full?
        return @slots.count { |e| !e.nil? } == BOX_SIZE
      end

      # Adds the Pokemon to this box if possible.
      # @param poke [Pokemon] the Pokemon to add.
      # @param index [NilClass, Integer] sets or overwrites the Pokemon in the given slot index.
      # @return [Boolean] whether or not the Pokemon could be added.
      def add_pokemon(poke, index = nil)
        if index
          @slots[index] = poke
          return true
        else
          for i in 0...@slots.size
            unless @slots[i]
              @slots[i] = poke
              return true
            end
          end
        end
        return false
      end
    end
  end
end
