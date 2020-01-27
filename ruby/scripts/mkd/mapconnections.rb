module MKD
  class MapConnections < Serializable
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

    # @param id [Numeric, NilClass] the ID of the map to fetch or nil to fetch all connections.
    # @return [Array<SystemID, MapX, MapY>] all map connections if no ID was specified, or the system the specified ID is in.
    def self.fetch(id = nil)
      if defined?(Cache)
        if id
          c = Cache.maps.find { |h| h.has_value?(id) }
          return nil unless c
          return [Cache.maps.index(c)].concat(c.keys.find { |k| c[k] == id })
        else
          return Cache
        end
      else
        self.const_set(:Cache, FileUtils.load_data("data/maps/connections.mkd", :map_connections))
        log(:SYSTEM, "Loaded map connections")
        return self.fetch(id)
      end
    end

    #temp
    def save
      FileUtils.save_data("data/maps/connections.mkd", :map_connections, self)
    end
  end
end
