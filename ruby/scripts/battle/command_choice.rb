class Battle
  class CommandChoice
    attr_accessor :value

    def initialize(value = nil)
      @value = value
    end

    def fight?
      return @value == 0
    end

    def bag?
      return @value == 1
    end

    def pokemon?
      return @value == 2
    end

    def run?
      return @value == 3
    end
  end
end
