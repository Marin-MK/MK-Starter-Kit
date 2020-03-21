module MKD
  class Map < Serializable
    Cache = []

    attr_accessor :id
    attr_accessor :dev_name
    attr_accessor :display_name
    attr_accessor :width
    attr_accessor :height
    attr_accessor :tiles
    attr_accessor :tilesets
    attr_accessor :autotiles
    attr_accessor :events
    attr_accessor :encounter_tables
    attr_accessor :connections
    attr_accessor :panoramas
    attr_accessor :fogs

    def panoramas
      return @panoramas ||= []
    end

    def fogs
      return @fogs ||= []
    end

    def initialize(id = 0)
      @id = id
      @dev_name = ""
      @display_name = ""
      @width = 0
      @height = 0
      @tiles = []
      @tilesets = [0]
      @autotiles = []
      @events = {}
      @encounter_tables = []
      @connections = []
      @panoramas = []
      @fogs = []
    end

    def encounter_tables
      return @encounter_tables ||= []
    end

    # @param [id] the ID of the map to fetch.
    # @return [Map] the map with the specified ID.
    def self.fetch(id)
      return Cache[id] if Cache[id]
      Cache[id] = FileUtils.load_data("data/maps/map#{id.to_digits(3)}.mkd", :map)
      return Cache[id]
    end

    def name
      return @display_name
    end

    #temp
    def save
      FileUtils.save_data("data/maps/map#{@id.to_digits}.mkd", :map, self)
    end
  end
end
