module MKD
	class Tileset
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

		def self.fetch(id = nil)
			if File.file?("data/tilesets.mkd")
			  data = FileUtils.load_data("data/tilesets.mkd")
			  return data unless id
			  return data[id]
			else
				return nil
			end
		end

    #temp
		def save
			data = MKD::Tileset.fetch || []
			data[@id] = self
			FileUtils.save_data("data/tilesets.mkd", data)
		end
	end
end