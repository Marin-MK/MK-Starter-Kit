def load_data(filename)
	return File.open(filename, 'rb') do |f|
		next Marshal.load(f)
	end
end

def save_data(filename, data)
  f = File.new(filename, 'wb')
  Marshal.dump(data, f)
  f.close
  return nil
end

class Numeric
	def to_digits(n = 3)
		str = self.to_s
		return str if str.size >= n
		(n - str.size).times { str = "0" + str }
		return str
	end
end

module MKD
	class Map
		attr_accessor :id
		attr_accessor :name
		attr_accessor :width
		attr_accessor :height
		attr_accessor :tiles
		attr_accessor :passabilities
		attr_accessor :priorities
		attr_accessor :tags
		attr_accessor :tileset_id

		def initialize(id)
			@id = id
			@name = ""
			@width = 0
			@height = 0
			@tiles = []
			@passabilities = []
			@priorities = []
			@tags = []
			@tileset_id = 0
		end

		def self.load(id)
			return load_data("data/maps/map#{id.to_digits(3)}.mkd") rescue nil
		end

		def save
			save_data("data/maps/map#{@id.to_digits}.mkd", self)
		end
	end
end

m = MKD::Map.load(0)
p m.name
m.name = "Test Town"
m.save
p m.name