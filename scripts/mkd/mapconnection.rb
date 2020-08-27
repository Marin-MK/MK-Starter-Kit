module MKD
  class MapConnection < Serializable
    attr_accessor :map_id
    attr_accessor :relative_x
    attr_accessor :relative_y

    def initialize(map_id, relative_x, relative_y)
      @map_id = map_id
      @relative_x = relative_x
      @relative_y = relative_y
    end
  end
end
