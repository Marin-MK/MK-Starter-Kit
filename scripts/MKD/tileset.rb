module MKD
	class Tileset
		attr_accessor :id
		attr_accessor :name
		attr_accessor :graphic
		attr_accessor :passabilities
		attr_accessor :priorities
		attr_accessor :tags

		def initialize(id)
			@id = id
			@name = ""
			@graphic = ""
			@priorities = []
			@passabilities = []
			@tags = []
		end

		def self.load(id = nil)
			data = load_data("data/tilesets.mkd")
			return data unless id
			return data[id]
		end

		def save
			data = MKD::Tileset.load
			data[@id] = self
			save_data("data/tilesets.mkd", data)
		end
	end
end