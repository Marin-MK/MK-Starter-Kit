class Game
  class Variables
    def initialize
      @values = []
    end

    def get(id)
      validate id => Fixnum
      return @values[id]
    end
    alias [] get

    def set(id, value)
      validate id => Fixnum
      @values[id] = value
    end
    alias []= set
  end
end