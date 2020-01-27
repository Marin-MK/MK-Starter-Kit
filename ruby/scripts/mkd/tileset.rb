module MKD
	class Tileset < Serializable
		Cache = []

		attr_accessor :id
		attr_accessor :name
		attr_accessor :graphic_name
		attr_accessor :passabilities
		attr_accessor :priorities
		attr_accessor :tags

		def initialize(id = 0)
			@id = id
			@name = ""
			@graphic_name = ""
			@priorities = []
			@passabilities = []
			@tags = []
		end

		# @param id [Integer, NilClass] the ID of the tileset to fetch.
		# @return [Tileset, Array] the tileset with the specified ID or the list of tilesets.
		def self.fetch(id = nil)
			if !Cache.empty?
				return id ? Cache[id] : Cache
			elsif File.file?("data/tilesets.mkd")
				tilesets = FileUtils.load_data("data/tilesets.mkd", :tilesets)
				Cache.replace(tilesets)
				log(:SYSTEM, "Loaded tilesets")
			  return Cache unless id
			  return Cache[id]
			end
		end

    #temp
		def save
			data = MKD::Tileset.fetch || []
			data[@id] = self
			FileUtils.save_data("data/tilesets.mkd", :tilesets, data)
		end
	end
end
