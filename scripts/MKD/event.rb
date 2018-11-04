module MKD
  class Event
    attr_accessor :id
    attr_accessor :name
    attr_accessor :name
    attr_accessor :states

    def initialize(id = 0)
      @id = id
      @name = ""
      @states = [State.new]
    end
  end
end

module MKD
  class Event
    class State
      attr_accessor :commands
      attr_accessor :graphic
      attr_accessor :trigger_mode
      attr_accessor :trigger_param

      def initialize
        @commands = []
        @graphic = Graphic.new
        @trigger_mode = 0
        @trigger_param = 0
      end
    end
  end
end

module MKD
  class Event
    class State
      class Graphic
        attr_accessor :type # 0 = standard or 1 = tile
        attr_accessor :param # filename or tile id
        attr_accessor :direction # :down, :left, :right, :up

        def initialize
          @type = 0
          @param = ""
          @direction = :down
        end
      end
    end
  end
end