module MKD
  class MapConnections
    Cache = nil

    attr_accessor :maps

    def initialize(maps = [])
      @maps = maps
    end

    def get_map_position(id)
      for i in 0...@maps.size
        if @maps[i].has_value?(id)
          return [i].concat(@maps.keys.find { |k| @maps[k] == id })
        end
      end
      return nil
    end

    def [](idx, x, y)
      return @maps[idx] ? @maps[idx][[x, y]] : nil
    end

    def []=(idx, x, y, value)
      @maps[idx] ||= {}
      @maps[idx][[x, y]] = value
    end

    # @param [id] the ID of the map to fetch.
    # @return [Map] the map with the specified ID.
    def self.fetch(idx = nil)
      return Cache if Cache
      self.const_set(:Cache, FileUtils.load_data("data/maps/connections.mkd"))
      return Cache[idx] if idx
      return Cache
    end

    #temp
    def save
      FileUtils.save_data("data/maps/connections.mkd", self)
    end
  end
end
