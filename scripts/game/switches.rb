class Game
  class Switches
    def initialize
      @values = []
    end

    def get(id)
      validate id => Fixnum
      return @values[id] == true
    end
    alias [] get

    def set(id, value)
      validate id => Fixnum, value => [FalseClass, TrueClass]
      @values[id] = value
    end
    alias []= set
  end
end