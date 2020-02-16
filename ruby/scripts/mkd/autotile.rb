module MKD
	class Autotile < Serializable
		Cache = []

		attr_accessor :id
		attr_accessor :name
    attr_accessor :format
		attr_accessor :graphic_name
		attr_accessor :passabilities
		attr_accessor :priorities
		attr_accessor :tags
		attr_accessor :animate_speed

		def initialize(id = 0)
			@id = id
			@name = ""
      @format = :legacy
			@graphic_name = ""
			@priorities = []
			@passabilities = []
			@tags = []
			@animate_speed = 10
		end

		# @param id [Integer, NilClass] the ID of the autotile to fetch.
		# @return [Autotile, Array] the autotile with the specified ID or the list of autotiles.
		def self.fetch(id = nil)
			if !Cache.empty?
				return id ? Cache[id] : Cache
			elsif File.file?("data/autotiles.mkd")
				autotiles = FileUtils.load_data("data/autotiles.mkd", :autotiles)
				Cache.replace(autotiles)
				log(:SYSTEM, "Loaded autotiles")
			  return Cache unless id
			  return Cache[id]
			end
		end

    #temp
		def save
			data = MKD::Autotile.fetch || []
			data[@id] = self
			FileUtils.save_data("data/autotiles.mkd", :autotiles, data)
		end
	end
end
