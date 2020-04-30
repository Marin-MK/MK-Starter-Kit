module MKD
  class Event < Serializable
    attr_accessor :id
    attr_accessor :name
    attr_accessor :x
    attr_accessor :y
    attr_accessor :width
    attr_accessor :height
    attr_accessor :pages

    def initialize(id = 0)
      @id = id
      @name = ""
      @x = 0
      @y = 0
      @width = 1
      @height = 1
      @pages = []
    end
  end
end

module MKD
  class Event
    class Settings < Serializable
      attr_accessor :move_animation
      attr_accessor :idle_animation
      attr_accessor :direction_lock
      attr_accessor :frame_update_interval
      attr_accessor :passable
      attr_accessor :save_position
      attr_accessor :speed

      def initialize
        @move_animation = true
        @idle_animation = false
        @direction_lock = false
        @frame_update_interval = 16
        @passable = false
        @save_position = true
        @speed = PLAYERWALKSPEED
      end
    end
  end
end

module MKD
  class Event
    class Page < Serializable
      attr_accessor :name
      attr_accessor :commands
      attr_accessor :conditions
      attr_accessor :graphic
      attr_accessor :trigger_mode
      attr_accessor :trigger_param
      attr_accessor :automoveroute
      attr_accessor :settings

      def initialize
        @name = ""
        @commands = []
        @conditions = []
        @graphic = Graphic.new
        @trigger_mode = :action
        @trigger_param = nil
        @automoveroute = AutoMoveRoute.new
        @settings = MKD::Event::Settings.new
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
      attr_accessor :num_directions
      attr_accessor :num_frames

      def initialize
        @type = :file
        @direction = 2
        @param = nil
        @frame_update_interval = 16
        @num_directions = 4
        @num_frames = 4
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
