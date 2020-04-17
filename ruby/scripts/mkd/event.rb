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
      attr_accessor :passable
      attr_accessor :save_position
      attr_accessor :speed

      def initialize
        @passable = true
        @save_position = true
        @speed = PLAYERWALKSPEED
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
      attr_accessor :trigger_mode
      attr_accessor :trigger_param
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
    class Graphic < Serializable
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
    class AutoMoveRoute < Serializable
      attr_accessor :frequency
      attr_accessor :commands

      def initialize
        @frequency = 1.3
        @commands = []
      end
    end
  end
end
