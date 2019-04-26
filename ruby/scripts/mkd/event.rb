module MKD
  class Event
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
    class Settings
      attr_accessor :priority
      attr_accessor :passable
      attr_accessor :can_start_surfing_here
      attr_accessor :reset_position_on_transfer
      attr_accessor :speed

      def initialize
        @priority = 1
        @passable = true
        @can_start_surfing_here = true
        @reset_position_on_transfer = true
        @speed = 2.2
      end
    end
  end
end

module MKD
  class Event
    class Page
      attr_accessor :commands
      attr_accessor :conditions
      attr_accessor :graphic
      attr_accessor :triggers
      attr_accessor :automoveroute

      def initialize
        @commands = []
        @conditions = []
        @graphic = {type: :file, direction: 2}
        @triggers = [:action]
        @automoveroute = {frequency: 80, commands: []}
      end
    end
  end
end
