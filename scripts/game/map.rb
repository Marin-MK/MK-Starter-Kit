class Game
  class Map
    attr_accessor :id
    attr_accessor :data

    def initialize(id = 0)
      @id = id
      @data = MKD::Map.fetch(id)
      Visuals::Map.create(self)
    end
  end
end