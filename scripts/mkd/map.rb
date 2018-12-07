module MKD
  class Map
    attr_accessor :id
    attr_accessor :name
    attr_accessor :width
    attr_accessor :height
    attr_accessor :tiles
    attr_accessor :passabilities
    attr_accessor :tags
    attr_accessor :tilesets
    attr_accessor :events

    def initialize(id = 0)
      @id = id
      @name = ""
      @width = 0
      @height = 0
      @tiles = []
      @passabilities = []
      @tags = []
      @tilesets = [0]
      @events = {}
    end

    def self.fetch(id)
      return FileUtils.load_data("data/maps/map#{id.to_digits(3)}.mkd")
    end

    #temp
    def save
      FileUtils.save_data("data/maps/map#{@id.to_digits}.mkd", self)
    end
  end
end