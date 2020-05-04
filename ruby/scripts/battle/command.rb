class Battle
  class Command
    attr_accessor :type
    attr_accessor :battler
    attr_accessor :argument

    def initialize(type, battler, *arguments)
      @type = type
      @battler = battler
      @arguments = arguments
    end

    def move
      return use_move? ? @arguments[0] : nil
    end

    def target
      return use_move? ? @arguments[1] : nil
    end

    def use_move?
      return @type == :use_move
    end
  end
end
