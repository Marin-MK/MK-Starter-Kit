module MKD
  class Event < Serializable
    attr_accessor :id
    attr_accessor :name
    attr_accessor :x
    attr_accessor :y
    attr_accessor :pages
    attr_accessor :settings

    def initialize(id = 0)
      @id = id
      @name = ""
      @x = 0
      @y = 0
      @pages = []
      @settings = MKD::Event::Settings.new
    end
  end
end

module MKD
  class Event
    class Settings < Serializable
      attr_accessor :priority
      attr_accessor :passable
      attr_accessor :can_start_surfing_here
      attr_accessor :save_position
      attr_accessor :speed

      def initialize
        @priority = 1
        @passable = true
        @can_start_surfing_here = true
        @save_position = true
        @speed = 2.2
      end
    end
  end
end

module MKD
  class Event
    class Page < Serializable
      attr_accessor :commands
      attr_accessor :conditions
      attr_accessor :graphic
      attr_accessor :triggers
      attr_accessor :automoveroute

      def initialize
        @commands = []
        @conditions = []
        @graphic = Graphic.new
        @trigger_mode = :action
        @trigger_param = nil
        @automoveroute = AutoMoveRoute.new
      end
    end
  end
end

module MKD
  class Event
    class Graphic
      attr_accessor :type
      attr_accessor :direction
      attr_accessor :param
      attr_accessor :frame_update_interval

      def initialize
        @type = :file
        @direction = 2
        @param = nil
        @frame_update_interval = 16
      end
    end
  end
end

module MKD
  class Event
    class AutoMoveRoute
      attr_accessor :frequency
      attr_accessor :commands

      def initialize
        @frequency = 80
        @commands = []
      end
    end
  end
end
